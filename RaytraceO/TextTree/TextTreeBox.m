%Create TextTreeBox object in current figure
%This function works with TextTreeBranch objects and creates a list that
%can be interactively selected and manipulated 
%The TextTreeBox box class is primarily responsible for controlling the
%graphical rendering of the TextTreeBox and also keeping track of the
%parameters corresponding to such.  TextTreeBox also keeps track of the
%parent branches in the tree as well as the scrollbars needed to help
%navigate the list..

%by way of info, empty checkboxes are char(9744) and checked checkboxes are
%char(9745).  Empty box is char(9634) and filled box is char(9635), arrows 9654 or 9655 and 9660 or 9661

classdef TextTreeBox < handle
    properties
        %access
        ParentFigure
        OldFigureSize
        Axes_h
        PrimaryBranchesCellArray %ChildrenBranches
        CurrentBranchesCellArray %All branches that can currently be viewed just by scrolling through the list
        VertScrollBar %for when the contents of the list extend beyond the reaches of the box
        HorzScrollBar %for when the contents of the list extend beyond the reaches of the box
        %functionality
        MultiselectAllowed %Boolean T/F
        ParentControlledChecking %means you check/uncheck the parent branch and all the children branches are checked/unchecked
        ParentControlledSelecting
        MaxStringSize
        MaxListLength
        %drawing
        CurrentRowIndents %column vector, saying how many indents to apply to the rows
        CurrentRowHighlights
        CurrentRowChecks
        CurrentListLength
        %looks
        SelectedColor
        RowHeight %in axes units (the default size is 1 by 1 when a new figure is opened
        IndentSize %the indent amount for each child level
        LineElementSpacing %how far apart the items on a line are spaced - in terms of PERCENTAGE OF THE INDENT SIZE
        TextSize %a font size
        ArrowSize %a font size
        CheckboxSize %a font size
        ExpandedArrowCharacter %of type char
        UnexpandedArrowCharacter %of type char
        CheckboxCheckedCharacter %of type char
        CheckboxUncheckedCharacter %of type char
        
    end
    
    
    methods
%% CREATION FUNCTION
        function TTBo=TextTreeBox()
            TTBo.ParentFigure=figure('MenuBar','none'); %COME BACK TO THIS
            fh=TTBo.ParentFigure;
            TTBo.OldFigureSize=fh.Position(3:4);
            TTBo.Axes_h=axes('Position',[.0,0,1,1],'YDir','reverse','XTick',{},'YTick',{});
            
            TTBo.PrimaryBranchesCellArray={};
            TTBo.CurrentBranchesCellArray={}; %All branches that can currently be viewed just by scrolling through the list
            TTBo.VertScrollBar=uicontrol('Style','Slider','Position',[fh.Position(3)-14,17,15,fh.Position(4)-30],'Value',1); %for when the contents of the list extend beyond the reaches of the box
            TTBo.HorzScrollBar=uicontrol('Style','Slider','Position',[15,5,fh.Position(3)-30,15]); %for when the contents of the list extend beyond the reaches of the box
            %functionality
            TTBo.ParentControlledChecking=false(1); %means you check/uncheck the parent branch and all the children branches are checked/unchecked
            TTBo.ParentControlledSelecting=false(1); %means you select the parent and the selection callbacks of the children execute
            TTBo.MultiselectAllowed=true(1); %Boolean T/F
            TTBo.MaxStringSize=60;
            TTBo.MaxListLength=1000;
            %drawing
            TTBo.CurrentRowIndents=[]; %column vector, saying how many indents to apply to the rows
            TTBo.CurrentRowHighlights=cell(0); %cell array 
            TTBo.CurrentRowChecks=cell(0);
            TTBo.CurrentListLength=0;
            %looks
            TTBo.SelectedColor=[.7,.7,1];
            TTBo.RowHeight=.06; %in axes units (the default size is 1 by 1 when a new figure is opened
            TTBo.IndentSize=.1; %the indent amount for each child level in axes units
            TTBo.LineElementSpacing=.33; %percentage of the indent size - should not go past .5
            TTBo.TextSize=12; %a font size
            TTBo.ArrowSize=12; %a font size
            TTBo.CheckboxSize=14; %a font size
            TTBo.ExpandedArrowCharacter=char(9660); %of type char or 9661
            TTBo.UnexpandedArrowCharacter=char(9658); %of type char or 9655
            TTBo.CheckboxCheckedCharacter=char(9745); %of type char or 9635
            TTBo.CheckboxUncheckedCharacter=char(9744); %of type char or 9634
            
            set(TTBo.ParentFigure,'SizeChangedFcn',{@ParentFigSizeChanged,TTBo});
            %nested function?
                                        function ParentFigSizeChanged(~,~,TTBo)
                                            ah=TTBo.Axes_h;
                                            if ~isempty(TTBo.ParentFigure) %this if statement is only here to avoid errors when loading a new optical system. Sometimes this function us run before the figure exists during loading.
                                            ah.XLim=[ah.XLim(1),ah.XLim(1)+(ah.XLim(2)-ah.XLim(1))*TTBo.ParentFigure.Position(3)/TTBo.OldFigureSize(1)];
                                            ah.YLim=[ah.YLim(1),ah.YLim(1)+(ah.YLim(2)-ah.YLim(1))*TTBo.ParentFigure.Position(4)/TTBo.OldFigureSize(2)];
                                            TTBo.OldFigureSize=TTBo.ParentFigure.Position(3:4);
                                            set(TTBo.HorzScrollBar,'Position',[15,5,TTBo.ParentFigure.Position(3)-30,10]);
                                            set(TTBo.VertScrollBar,'Position',[TTBo.ParentFigure.Position(3)-14,17,15,TTBo.ParentFigure.Position(4)-30]);
                                            drawTextTreeBox(TTBo);
                                            end
                                        end
            
            TTBo.VertScrollBar.Callback={@VertScrollBar_Callback,TTBo};
                                        function VertScrollBar_Callback(objh,~,TTBo) %this just changes the axes limits
                                            maxpos=(TTBo.CurrentListLength-1)*TTBo.RowHeight;
                                            movetohere=(1-objh.Value)*maxpos;
                                            spacing=TTBo.Axes_h.YLim(2)-TTBo.Axes_h.YLim(1);
                                            TTBo.Axes_h.YLim=[movetohere,movetohere+spacing];
                                            drawTextTreeBox(TTBo);
                                        end
            TTBo.HorzScrollBar.UserData=.1;
            TTBo.HorzScrollBar.UIContextMenu=uicontextmenu(TTBo.ParentFigure);
            uimenu(TTBo.HorzScrollBar.UIContextMenu,'Label','Set scroll shift amount','Callback',@(hobj,evd)setshift(TTBo.HorzScrollBar));
                                        function setshift(hscroll)
                                            outval=str2double(inputdlg(['The current set value is ',num2str(hscroll.UserData),'. Choose the new value to use in order to reduce or expand the horizontal scrolling shift amount.']));
                                            if isfinite(outval), hscroll.UserData=outval; end
                                        end
            TTBo.HorzScrollBar.Callback={@HorzScrollBar_Callback,TTBo};
                                        function HorzScrollBar_Callback(objh,~,TTBo) %this just changes the axes limits
                                            TTBo.Axes_h.XLim=TTBo.Axes_h.XLim-TTBo.Axes_h.XLim(1);
                                            TTBo.Axes_h.XLim=TTBo.Axes_h.XLim+objh.UserData*objh.Value;
                                        end
                       
            fh.WindowScrollWheelFcn={@mousescroll,TTBo};
            
                                        function mousescroll(~,callbackdata,TTBo) %this just changes the axes limits
                                            shiftAxes(TTBo,callbackdata.VerticalScrollCount/15)
                                            drawTextTreeBox(TTBo);
                                        end
                                        
%             fh.WindowButtonDownFcn={@whatbutton};
%                                         function whatbutton(cbh,cbd)
% % %                                             get(cbh)
% %                                             disp ' '
% %                                             disp ' '
% % %                                             get(cbd)
%                                         end
            
            mainmenu=uimenu(TTBo.ParentFigure,'Label','Tree');
                uimenu(mainmenu,'Label','Find','Callback','disp(''find'')');
                actionmenu=uimenu(mainmenu,'Label','Actions');
                    uimenu(actionmenu,'Label','Expand All','Callback',{@menuExpandAll,TTBo});
                                                    function menuExpandAll(~,~,TTBo)
                                                        expandAll(TTBo); drawTextTreeBox(TTBo);
                                                    end
                    uimenu(actionmenu,'Label','Collapse All','Callback',{@menuCollapseAll,TTBo});
                                                    function menuCollapseAll(~,~,TTBo)
                                                        collapseAll(TTBo); drawTextTreeBox(TTBo);
                                                    end
                    uimenu(actionmenu,'Label','Select All','Callback',{@menuSelectAll,TTBo});
                                                    function menuSelectAll(~,~,TTBo)
                                                        selectAll(TTBo); drawTextTreeBox(TTBo);
                                                    end
                    uimenu(actionmenu,'Label','Deselect All','Callback',{@menuDeselectAll,TTBo});
                                                    function menuDeselectAll(~,~,TTBo)
                                                        deselectAll(TTBo); drawTextTreeBox(TTBo);
                                                    end
                    uimenu(actionmenu,'Label','Check All','Callback',{@menuCheckAll,TTBo});
                                                    function menuCheckAll(~,~,TTBo)
                                                        checkAll(TTBo); drawTextTreeBox(TTBo);
                                                    end
                    uimenu(actionmenu,'Label','Uncheck All','Callback',{@menuUncheckAll,TTBo});
                                                    function menuUncheckAll(~,~,TTBo)
                                                        uncheckAll(TTBo); drawTextTreeBox(TTBo);
                                                    end
                settingsmenu=uimenu(mainmenu,'Label','Settings');
                    functionalitymenu=uimenu(settingsmenu,'Label','Functionality');
                        uimenu(functionalitymenu,'Label',['MultiSelect ',char(10003)],'Callback',{@MultiSelectOnOff,TTBo});
                                                                                                                            function MultiSelectOnOff(hobj,~,TTBo)
                                                                                                                                TTBo.MultiselectAllowed=~TTBo.MultiselectAllowed;
                                                                                                                                if TTBo.MultiselectAllowed, hobj.Label=['MultiSelect ',char(10003)]; else hobj.Label=['MultiSelect ',char(10005)]; end
                                                                                                                            end
                        uimenu(functionalitymenu,'Label',['Parent Controlled Checking ',char(10005)],'Callback',{@PCCOnOff,TTBo});
                                                                                                                            function PCCOnOff(hobj,~,TTBo)
                                                                                                                                TTBo.ParentControlledChecking=~TTBo.ParentControlledChecking;
                                                                                                                                if TTBo.ParentControlledChecking, hobj.Label=['Parent Controlled Checking ',char(10003)]; else hobj.Label=['Parent Controlled Checking ',char(10005)]; end
                                                                                                                            end
                        uimenu(functionalitymenu,'Label',['Parent Controlled Selection ',char(10005)],'Callback',{@PCSOnOff,TTBo});
                                                                                                                            function PCSOnOff(hobj,~,TTBo)
                                                                                                                                TTBo.ParentControlledSelecting=~TTBo.ParentControlledSelecting;
                                                                                                                                if TTBo.ParentControlledSelecting, hobj.Label=['Parent Controlled Selection ',char(10003)]; else hobj.Label=['Parent Controlled Selection ',char(10005)]; end
                                                                                                                            end
                        uimenu(functionalitymenu,'Label',['Max Chars per line: ',num2str(TTBo.MaxStringSize)],'Callback',{@MaxStringSizeOnOff,TTBo});
                                                                                                                            function MaxStringSizeOnOff(hobj,~,TTBo)
                                                                                                                                TTBo.MaxStringSize=NaN;
                                                                                                                                while any([isnan(TTBo.MaxStringSize),isempty(TTBo.MaxStringSize)]);
                                                                                                                                TTBo.MaxStringSize=str2double(inputdlg('Put in an integer between 20 and 200'));
                                                                                                                                class(isempty(TTBo.MaxStringSize))
                                                                                                                                end
                                                                                                                                TTBo.MaxStringSize=round(TTBo.MaxStringSize); if TTBo.MaxStringSize<10, TTBo.MaxStringSize=10; end; if TTBo.MaxStringSize>200, TTBo.MaxStringSize=200; end
                                                                                                                                hobj.Label=['Max Chars per line: ',num2str(TTBo.MaxStringSize)];
                                                                                                                            end
                        uimenu(functionalitymenu,'Label',['Maximum List Size: ',num2str(TTBo.MaxListLength)],'Callback',{@MaxListLengthOnOff,TTBo});
                                                                                                                            function MaxListLengthOnOff(hobj,~,TTBo)
                                                                                                                                TTBo.MaxListLength=NaN;
                                                                                                                                while any([isnan(TTBo.MaxListLength),isempty(TTBo.MaxListLength)]);
                                                                                                                                TTBo.MaxListLength=str2double(inputdlg('Put in an integer'));
                                                                                                                                end
                                                                                                                                TTBo.MaxListLength=round(TTBo.MaxListLength);
                                                                                                                                hobj.Label=['Maximum List Size: ',num2str(TTBo.MaxListLength)];
                                                                                                                            end
                    appearancemenu=uimenu(settingsmenu,'Label','Appearance');
                        uimenu(appearancemenu,'Label','Color of Selected','Callback','disp(''SelColor'')');
                        uimenu(appearancemenu,'Label','Row Height','Callback','disp(''RowHeight'')');
                        uimenu(appearancemenu,'Label','Text Size','Callback','disp(''SizeText'')');
                        uimenu(appearancemenu,'Label','Indent Size','Callback','disp(''SizeIndent'')');
                        uimenu(appearancemenu,'Label','Checkbox Size','Callback','disp(''SizeCheckbox'')');
                        uimenu(appearancemenu,'Label','ExpandArrow Size','Callback','disp(''SizeExpArrow'')');
        end
        
        
        
        
%% CURRENTS UPDATING        
        function UpdateAllCurrents(TTBo)
            TTBo.CurrentBranchesCellArray=cell(TTBo.MaxListLength,1); %initialize
            TTBo.CurrentRowIndents=zeros(TTBo.MaxListLength,1); %initialize
            TTBo.CurrentRowHighlights=cell(TTBo.MaxListLength,1); %initialize
            TTBo.CurrentRowChecks=cell(TTBo.MaxListLength,1); %initialize
            if ~isempty(TTBo.PrimaryBranchesCellArray)
                currentline=0;
                for n=1:length(TTBo.PrimaryBranchesCellArray)
                    currentline=currentline+1;
                    TTBo.CurrentBranchesCellArray{currentline}=TTBo.PrimaryBranchesCellArray{n};
                    TTBo.CurrentRowIndents(currentline)=0;
                    if TTBo.CurrentBranchesCellArray{currentline}.isSelected
                        TTBo.CurrentRowHighlights{currentline}=TTBo.SelectedColor; else TTBo.CurrentRowHighlights{currentline}='none';
                    end
                    if TTBo.CurrentBranchesCellArray{currentline}.isChecked
                        TTBo.CurrentRowChecks{currentline}=TTBo.CheckboxCheckedCharacter; else TTBo.CurrentRowChecks{currentline}=TTBo.CheckboxUncheckedCharacter;
                    end
                    if all([TTBo.PrimaryBranchesCellArray{n}.hasChildren,TTBo.PrimaryBranchesCellArray{n}.isExpanded])
                        currentline=WriteupCurrents(TTBo,TTBo.PrimaryBranchesCellArray{n},0,currentline);
                    end
                end
                TTBo.CurrentListLength=currentline;
            end
        end
        
        
        function currentline=WriteupCurrents(TTBo,ParentBranch,recursionlevel,currentline) %recursionlevel and currentline both start at zero
            if ParentBranch.hasChildren
                for n=1:length(ParentBranch.ChildrenBranches)
                    currentline=currentline+1;
                    if currentline>TTBo.MaxListLength, error('Your list has expanded beyond the max list length'); end                        
                    TTBo.CurrentBranchesCellArray{currentline}=ParentBranch.ChildrenBranches{n};
                    TTBo.CurrentRowIndents(currentline)=recursionlevel+1;
                    if TTBo.CurrentBranchesCellArray{currentline}.isSelected
                        TTBo.CurrentRowHighlights{currentline}=TTBo.SelectedColor; else TTBo.CurrentRowHighlights{currentline}='none';
                    end
                    if TTBo.CurrentBranchesCellArray{currentline}.isChecked
                        TTBo.CurrentRowChecks{currentline}=TTBo.CheckboxCheckedCharacter; else TTBo.CurrentRowChecks{currentline}=TTBo.CheckboxUncheckedCharacter;
                    end
                    if all([ParentBranch.ChildrenBranches{n}.hasChildren, ParentBranch.ChildrenBranches{n}.isExpanded])
                        currentline=WriteupCurrents(TTBo,ParentBranch.ChildrenBranches{n},recursionlevel+1,currentline);
                    end
                end
                TTBo.CurrentListLength=currentline;
            end
        end
        
%% BRANCH EXPANSION AND COLLAPSE
        function NewRowNumber=ExpandBranch(TTBo, RowNumber) %this doesn't expand any appearances of the branch that are in other TextTreeBoxes.  Branchline updates the clicked line to be the new location if any lines prior to the clicked line are expanded.
            branchhandle=TTBo.CurrentBranchesCellArray{RowNumber}; %rename to make easy on the eyes
            if branchhandle.hasChildren %make sure you need to expand something
                branchhandle.isExpanded=true(1); %change the actual object state to be expanded
                n=1;%initialize the row counter
                while n<=TTBo.CurrentListLength %as long as you haven't hit the end of the list
                    if branchhandle==TTBo.CurrentBranchesCellArray{n} %If any of the list appearances match the TextTreeBranch object that was clicked
                        %Split the currents at row n and move the remainder to the back end of each list 
                        listlength=(TTBo.CurrentListLength-n); %say what the length of the list is that you are shifting to the back end
                        movelistto=TTBo.MaxListLength-listlength+1; %index number you shift the chunk to
                        %split & shift all currents back
                        TTBo.CurrentBranchesCellArray(movelistto:TTBo.MaxListLength)=TTBo.CurrentBranchesCellArray((n+1):TTBo.CurrentListLength);
                        TTBo.CurrentRowIndents(movelistto:TTBo.MaxListLength)=TTBo.CurrentRowIndents((n+1):TTBo.CurrentListLength);
                        TTBo.CurrentRowHighlights(movelistto:TTBo.MaxListLength)=TTBo.CurrentRowHighlights((n+1):TTBo.CurrentListLength);
                        TTBo.CurrentRowChecks(movelistto:TTBo.MaxListLength)=TTBo.CurrentRowChecks((n+1):TTBo.CurrentListLength);

                        currentline=WriteupCurrents(TTBo,TTBo.CurrentBranchesCellArray{n},TTBo.CurrentRowIndents(n),n); %update the currents lists from the split line and add in all the children, keeping track of rownumber
                        if n<RowNumber, RowNumber=RowNumber+currentline-n; end %if you've expanded a prior appearance of the list item, then update rownumber to the new rownumber at which the originally specified row will now appear
                        n=currentline; %now that you've expanded a part of the list, move n to where the expanding ended
                        if n>=movelistto %if you have passed where you moved the old list chunk to, then your list is now too long
                            TTBo.CurrentListLength=TTBo.MaxListLength;
                            msgbox('Your list expanded beyond the limit of the TextTreeBox settings.  Change the setting to allow for longer lists and reinitiate.');
                        else
                            %shift everything back over to the current line
                            TTBo.CurrentBranchesCellArray(currentline+1:currentline+listlength)=TTBo.CurrentBranchesCellArray(movelistto:TTBo.MaxListLength);
                            TTBo.CurrentRowIndents(currentline+1:currentline+listlength)=TTBo.CurrentRowIndents(movelistto:TTBo.MaxListLength);
                            TTBo.CurrentRowHighlights(currentline+1:currentline+listlength)=TTBo.CurrentRowHighlights(movelistto:TTBo.MaxListLength);
                            TTBo.CurrentRowChecks(currentline+1:currentline+listlength)=TTBo.CurrentRowChecks(movelistto:TTBo.MaxListLength);
                            TTBo.CurrentListLength=currentline+listlength;
                            %clear out the tail ends
                            TTBo.CurrentBranchesCellArray(TTBo.CurrentListLength+1:TTBo.MaxListLength)=cell(TTBo.MaxListLength-TTBo.CurrentListLength,1);
                            TTBo.CurrentRowIndents(TTBo.CurrentListLength+1:TTBo.MaxListLength)=0;
                            TTBo.CurrentRowHighlights(TTBo.CurrentListLength+1:TTBo.MaxListLength)=cell(TTBo.MaxListLength-TTBo.CurrentListLength,1);
                            TTBo.CurrentRowChecks(TTBo.CurrentListLength+1:TTBo.MaxListLength)=cell(TTBo.MaxListLength-TTBo.CurrentListLength,1);
                        end
                    end
                    n=n+1;
                end
            end
            NewRowNumber=RowNumber;
        end
        
        function NewRowNumber=CollapseBranch(TTBo, RowNumber) %this doesn't collapse this branch in other TextTreeBoxes but the one specified by TTBo
            branchhandle=TTBo.CurrentBranchesCellArray{RowNumber};
            branchhandle.isExpanded=false(1);
            n=1; %start the row counter
            while n<=TTBo.CurrentListLength %as long as you haven't hit the end of the list
                if branchhandle==TTBo.CurrentBranchesCellArray{n} %If any of the list appearances match the TextTreeBranch object that was clicked
                    nextbranch=n+1;
                    while TTBo.CurrentRowIndents(nextbranch)>TTBo.CurrentRowIndents(n) %update nextbranch to the next line where the indent size is the same
                        nextbranch=nextbranch+1;
                    end
                    collapsesize=(nextbranch-n-1); %how many lines to collapse
                    if n<RowNumber, RowNumber=RowNumber-collapsesize; end %if you collapsed a list appearance that came before the originally specified rownumber
                    %shift the lines back
                    %set the indices
                    numLinestoShift=TTBo.CurrentListLength-nextbranch+1;
                    indicestoshiftthemto=n+1:n+numLinestoShift;
                    linestoshiftup=nextbranch:TTBo.CurrentListLength;
                    %Updates the currents
                    TTBo.CurrentBranchesCellArray(indicestoshiftthemto)=TTBo.CurrentBranchesCellArray(linestoshiftup);
                    TTBo.CurrentRowIndents(indicestoshiftthemto)=TTBo.CurrentRowIndents(linestoshiftup);
                    TTBo.CurrentRowHighlights(indicestoshiftthemto)=TTBo.CurrentRowHighlights(linestoshiftup);
                    TTBo.CurrentRowChecks(indicestoshiftthemto)=TTBo.CurrentRowChecks(linestoshiftup);
                    TTBo.CurrentListLength=n+numLinestoShift;
                    %clear out the tail ends
                    TTBo.CurrentBranchesCellArray(TTBo.CurrentListLength+1:TTBo.MaxListLength)=cell(TTBo.MaxListLength-TTBo.CurrentListLength,1);
                    TTBo.CurrentRowIndents(TTBo.CurrentListLength+1:TTBo.MaxListLength)=0;
                    TTBo.CurrentRowHighlights(TTBo.CurrentListLength+1:TTBo.MaxListLength)=cell(TTBo.MaxListLength-TTBo.CurrentListLength,1);
                    TTBo.CurrentRowChecks(TTBo.CurrentListLength+1:TTBo.MaxListLength)=cell(TTBo.MaxListLength-TTBo.CurrentListLength,1);
                end
                n=n+1;
            end
            NewRowNumber=RowNumber;
        end

%% Select/Deselect all
        function selectAll(TTBo)
            for n=1:TTBo.CurrentListLength
                if ~TTBo.CurrentBranchesCellArray{n}.isSelected
                    TTBo.CurrentBranchesCellArray{n}.isSelected=true(1);
                    notify(TTBo.CurrentBranchesCellArray{n},'gotSelected');
                end
                TTBo.CurrentRowHighlights{n}=TTBo.SelectedColor;
                if all([TTBo.CurrentBranchesCellArray{n}.hasChildren,~TTBo.CurrentBranchesCellArray{n}.isExpanded])
                    selectchildren(TTBo.CurrentBranchesCellArray{n});
                end
            end
            function selectchildren(TTBr)
                for nn=1:length(TTBr.ChildrenBranches)
                    if ~TTBr.ChildrenBranches{nn}.isSelected
                        TTBr.ChildrenBranches{nn}.isSelected=true(1);
                        notify(TTBr.ChildrenBranches{nn},'gotSelected');
                    end
                    if TTBr.ChildrenBranches{nn}.hasChildren
                        selectchildren(TTBr.ChildrenBranches{nn})
                    end
                end
            end
        end
        
        function deselectAll(TTBo)
            for n=1:TTBo.CurrentListLength
                if TTBo.CurrentBranchesCellArray{n}.isSelected
                    TTBo.CurrentBranchesCellArray{n}.isSelected=false(1);
                    notify(TTBo.CurrentBranchesCellArray{n},'gotDeselected');
                end
                TTBo.CurrentRowHighlights{n}='none';
                if all([TTBo.CurrentBranchesCellArray{n}.hasChildren,~TTBo.CurrentBranchesCellArray{n}.isExpanded])
                    deselectchildren(TTBo.CurrentBranchesCellArray{n});
                end
            end
            function deselectchildren(TTBr)
                for nn=1:length(TTBr.ChildrenBranches)
                    if TTBr.ChildrenBranches{nn}.isSelected
                        TTBr.ChildrenBranches{nn}.isSelected=false(1);
                        notify(TTBr.ChildrenBranches{nn},'gotDeselected');
                    end
                    if TTBr.ChildrenBranches{nn}.hasChildren
                        deselectchildren(TTBr.ChildrenBranches{nn})
                    end
                end
            end
        end
        

%% Select/Deselect branch
        function deselectBranch(TTBo,TTBr)
            if TTBr.isSelected
                TTBr.isSelected=false(1);
                notify(TTBr,'gotDeselected');
            end
            rowset=findRowNumbersOfAllVisibleCopies(TTBo,TTBr);
            for n=rowset
                TTBo.CurrentRowHighlights{n}='none';
            end
            %the parentcontrolledselecting part
            if all([TTBo.ParentControlledSelecting,TTBr.hasChildren])
                for nn=1:length(TTBr.ChildrenBranches)
                    deselectBranch(TTBo,TTBr.ChildrenBranches{nn});
                end
            end
        end
        
        function selectBranch(TTBo,TTBr)
            if ~TTBo.MultiselectAllowed
                deselectAll(TTBo)
            end
            if ~TTBr.isSelected
                TTBr.isSelected=true(1);
                notify(TTBr,'gotSelected');
            end
            rowset=findRowNumbersOfAllVisibleCopies(TTBo,TTBr);
            for n=rowset
                TTBo.CurrentRowHighlights{n}=TTBo.SelectedColor;
            end
            %the parentcontrolledselecting part
            if all([TTBo.ParentControlledSelecting,TTBr.hasChildren,TTBo.MultiselectAllowed])
                for nn=1:length(TTBr.ChildrenBranches)
                    selectBranch(TTBo,TTBr.ChildrenBranches{nn});
                end
            end
        end
        
%% Check/Uncheck Branch
        function uncheckBranch(TTBo,TTBr)
            if TTBr.isChecked
                TTBr.isChecked=false(1);
                notify(TTBr,'gotUnchecked');
            end
            rowset=findRowNumbersOfAllVisibleCopies(TTBo,TTBr);
            for n=rowset
                TTBo.CurrentRowChecks{n}=TTBo.CheckboxUncheckedCharacter;
            end
            %the parentcontrolledchecking part
            if all([TTBo.ParentControlledChecking,TTBr.hasChildren])
                for nn=1:length(TTBr.ChildrenBranches)
                    uncheckBranch(TTBo,TTBr.ChildrenBranches{nn});
                end
            end
        end
        
        function checkBranch(TTBo,TTBr)
            if ~TTBr.isChecked
                TTBr.isChecked=true(1);
                notify(TTBr,'gotChecked');
            end
            rowset=findRowNumbersOfAllVisibleCopies(TTBo,TTBr);
            for n=rowset
                TTBo.CurrentRowChecks{n}=TTBo.CheckboxCheckedCharacter;
            end
            %the parentcontrolledchecking part
            if all([TTBo.ParentControlledChecking,TTBr.hasChildren])
                for nn=1:length(TTBr.ChildrenBranches)
                    checkBranch(TTBo,TTBr.ChildrenBranches{nn});
                end
            end
        end
%% CHECK/UNCHECK ALL
        function checkAll(TTBo)
            for n=1:TTBo.CurrentListLength
                if ~TTBo.CurrentBranchesCellArray{n}.isChecked
                    TTBo.CurrentBranchesCellArray{n}.isChecked=true(1);
                    notify(TTBo.CurrentBranchesCellArray{n},'gotChecked');
                end
                TTBo.CurrentRowChecks{n}=TTBo.CheckboxCheckedCharacter;
                if all([TTBo.CurrentBranchesCellArray{n}.hasChildren,~TTBo.CurrentBranchesCellArray{n}.isExpanded])
                    checkchildren(TTBo.CurrentBranchesCellArray{n});
                end
            end
            function checkchildren(TTBr)
                for nn=1:length(TTBr.ChildrenBranches)
                    if ~TTBr.ChildrenBranches{nn}.isChecked
                        TTBr.ChildrenBranches{nn}.isChecked=true(1);
                        notify(TTBr.ChildrenBranches{nn},'gotChecked');
                    end
                    if TTBr.ChildrenBranches{nn}.hasChildren
                        checkchildren(TTBr.ChildrenBranches{nn})
                    end
                end
            end
        end
        
        function uncheckAll(TTBo)
            for n=1:TTBo.CurrentListLength
                if TTBo.CurrentBranchesCellArray{n}.isChecked
                    TTBo.CurrentBranchesCellArray{n}.isChecked=false(1);
                    notify(TTBo.CurrentBranchesCellArray{n},'gotUnchecked');
                end
                TTBo.CurrentRowChecks{n}=TTBo.CheckboxUncheckedCharacter;
                if all([TTBo.CurrentBranchesCellArray{n}.hasChildren,~TTBo.CurrentBranchesCellArray{n}.isExpanded])
                    uncheckchildren(TTBo.CurrentBranchesCellArray{n});
                end
            end
            function uncheckchildren(TTBr)
                for nn=1:length(TTBr.ChildrenBranches)
                    if TTBr.ChildrenBranches{nn}.isChecked
                        TTBr.ChildrenBranches{nn}.isChecked=false(1);
                        notify(TTBr.ChildrenBranches{nn},'gotUnchecked');
                    end
                    if TTBr.ChildrenBranches{nn}.hasChildren
                        uncheckchildren(TTBr.ChildrenBranches{nn})
                    end
                end
            end
        end

        
%% EXPAND/COLLAPSE ALL
function expandAll(TTBo)
    n=1;
    while n<=TTBo.CurrentListLength
        if all([TTBo.CurrentBranchesCellArray{n}.hasChildren,~TTBo.CurrentBranchesCellArray{n}.isExpanded])
            ExpandBranch(TTBo,n);
        end
        n=n+1;
    end
end

function collapseAll(TTBo)
    n=1;
    while n<=TTBo.CurrentListLength
        if all([TTBo.CurrentBranchesCellArray{n}.hasChildren,TTBo.CurrentBranchesCellArray{n}.isExpanded])
            CollapseBranch(TTBo,n);
        end
        n=n+1;
    end
end
        
        
%% DrawTextTreeBox        
        function drawTextTreeBox(TTBo)
            ah=TTBo.Axes_h;
            delete(ah.Children);
            startlinenumber=max(floor(ah.YLim(1)/TTBo.RowHeight)-1,1);
            endlinenumber=min(ceil(ah.YLim(2)/TTBo.RowHeight)+1,TTBo.CurrentListLength);
            
            if TTBo.CurrentListLength>0
                for n=startlinenumber:endlinenumber
                    figure(TTBo.ParentFigure)
                    text((TTBo.CurrentRowIndents(n)+1)*TTBo.IndentSize, n*TTBo.RowHeight,TTBo.CurrentBranchesCellArray{n}.String,'BackgroundColor',TTBo.CurrentRowHighlights{n},'ButtonDownFcn',{@textpressed,TTBo,n},'FontSize',TTBo.TextSize,'UIContextMenu',TTBo.CurrentBranchesCellArray{n}.UIContextMenu,'Parent',TTBo.Axes_h);
                    if TTBo.CurrentBranchesCellArray{n}.hasChildren
                        if TTBo.CurrentBranchesCellArray{n}.isExpanded
                            text((TTBo.CurrentRowIndents(n)+1-TTBo.LineElementSpacing)*TTBo.IndentSize, n*TTBo.RowHeight, TTBo.ExpandedArrowCharacter,'FontSize',TTBo.ArrowSize,'ButtonDownFcn',{@arrowpressed,TTBo,n},'Parent',TTBo.Axes_h);
                        else
                            text((TTBo.CurrentRowIndents(n)+1-TTBo.LineElementSpacing)*TTBo.IndentSize, n*TTBo.RowHeight, TTBo.UnexpandedArrowCharacter,'FontSize',TTBo.ArrowSize,'ButtonDownFcn',{@arrowpressed,TTBo,n},'Parent',TTBo.Axes_h);
                        end
                    end
                    text((TTBo.CurrentRowIndents(n)+1-2*TTBo.LineElementSpacing)*TTBo.IndentSize, n*TTBo.RowHeight, TTBo.CurrentRowChecks{n},'FontSize',TTBo.CheckboxSize,'ButtonDownFcn',{@checkmarkpressed,TTBo,n},'Parent',TTBo.Axes_h);
                end
            end
                                    function textpressed(~,~,TTBo,RowNumber)
                                        if strcmpi(get(TTBo.ParentFigure,'SelectionType'),'normal')
                                            if TTBo.CurrentBranchesCellArray{RowNumber}.isSelected
                                                deselectBranch(TTBo,TTBo.CurrentBranchesCellArray{RowNumber}); drawTextTreeBox(TTBo); else selectBranch(TTBo,TTBo.CurrentBranchesCellArray{RowNumber}); drawTextTreeBox(TTBo);
                                            end    
                                        elseif strcmpi(get(TTBo.ParentFigure,'SelectionType'),'alt')
                                            %then open uicontextmenu - no code needed here. The nature of UIContextMenu's is that they are already programmed by Matlab to open with a right-click
                                        elseif strcmpi(get(TTBo.ParentFigure,'SelectionType'),'extend') %this is a shift-click
                                            if TTBo.MultiselectAllowed %if you can mulitselect
                                                %find prior highlighted row
                                                rn=RowNumber-1;
                                                while all([rn>1,strcmpi(TTBo.CurrentRowHighlights{rn},'none')]) %look for other highlighted rows
                                                    rn=rn-1; %go down the lines
                                                end
                                                if strcmpi(TTBo.CurrentRowHighlights{rn},'none'), rn=rn-1; end
                                                if rn>0 %if you found a highlighted row before the beginning of the list
                                                    for mm=rn:RowNumber %go through all the rows to highlight
                                                        selectBranch(TTBo,mm)
                                                    end
                                                end
                                            end
%                             elseif strcmpi(get(TTBo.ParentFigure,'SelectionType'),'open')
%                                 %Then expand/contract -arrowpressed checks if it has children first
%                                 arrowpressed(1,1,TTBo,RowNumber)
                                        end
                                        
                                    end
                                    function arrowpressed(~,~,TTBo,RowNumber)
                                        if TTBo.CurrentBranchesCellArray{RowNumber}.isExpanded
                                            NewRowNumber=CollapseBranch(TTBo,RowNumber);
                                            shiftAxes(TTBo,(NewRowNumber-RowNumber)*TTBo.RowHeight)
                                            drawTextTreeBox(TTBo);
                                        else
                                            NewRowNumber=ExpandBranch(TTBo,RowNumber);
                                            shiftAxes(TTBo,(NewRowNumber-RowNumber)*TTBo.RowHeight)
                                            drawTextTreeBox(TTBo);
                                        end
                                    end
                                    function checkmarkpressed(~,~,TTBo,RowNumber)
                                        if TTBo.CurrentBranchesCellArray{RowNumber}.isChecked
                                            uncheckBranch(TTBo,TTBo.CurrentBranchesCellArray{RowNumber}); drawTextTreeBox(TTBo); else checkBranch(TTBo,TTBo.CurrentBranchesCellArray{RowNumber}); drawTextTreeBox(TTBo);
                                        end
                                    end
        end

%% ADD PRIMARY BRANCHES        
        function addPrimaryBranches(TTBox,CellArrayofTextTreeBranches)
            if ~isa(CellArrayofTextTreeBranches,'cell'), error('addPrimaryBranches expects a cell array as the second argument'), end
            for n=1:length(CellArrayofTextTreeBranches)
                if ~isa(CellArrayofTextTreeBranches{n},'TextTreeBranch')
                    error('All elements of the second argument need to be of class TextTreeBranch')
                end
            end
            TTBox.PrimaryBranchesCellArray=[TTBox.PrimaryBranchesCellArray,CellArrayofTextTreeBranches];
            removeDuplicatePrimaryBranches(TTBox);
            for n=1:length(CellArrayofTextTreeBranches)
                if ~hasTheseParents(CellArrayofTextTreeBranches{n},{TTBox})
                    addParentBoxes(CellArrayofTextTreeBranches{n},{TTBox})
                end
            end
            UpdateAllCurrents(TTBox)
            drawTextTreeBox(TTBox)
        end
%% PRIMARY BRANCH REMOVAL        
        function removePrimaryBranches(TTBox,cellArrayOfTextTreeBranches)
            if ~isa(cellArrayOfTextTreeBranches,'cell'), error('removePrimaryBranches expects a cell array as the second argument'), end
            keepers=true(1,length(TTBox.PrimaryBranchesCellArray));
            for n=1:length(TTBox.PrimaryBranchesCellArray)
                for m=1:length(cellArrayOfTextTreeBranches)
                    if TTBox.PrimaryBranchesCellArray{n}==cellArrayOfTextTreeBranches{m}
                        if hasTheseParents(TTBox.PrimaryBranchesCellArray{n},{TTBox})
                            temp=TTBox.PrimaryBranchesCellArray{n};
                            TTBox.PrimaryBranchesCellArray{n}={};%remove the child first to avoid infinite looping between the two removal functions
                            removeParentBoxes(temp,{TTBox});
                        end
                        keepers(n)=0;
                    end
                end
            end
            TTBox.PrimaryBranchesCellArray=TTBox.PrimaryBranchesCellArray(keepers);
        end
        
 %% NO DUPLICATE PRIMARY BRANCHES
        function removeDuplicatePrimaryBranches(TTBox)
            keepers=true(1,length(TTBox.PrimaryBranchesCellArray));
            for n=1:(length(TTBox.PrimaryBranchesCellArray)-1)
                for m=(n+1):length(TTBox.PrimaryBranchesCellArray)
                    if TTBox.PrimaryBranchesCellArray{n}==TTBox.PrimaryBranchesCellArray{m}, keepers(m)=0; end
                end
            end
            TTBox.PrimaryBranchesCellArray=TTBox.PrimaryBranchesCellArray(keepers);
        end
        
%% FIND COPIES OF BRANCH - for finding mulitples of a TextTreeBranch within a single TextTreeBox
        function RowNumbers=findRowNumbersOfAllVisibleCopies(TTBo,TTBr)
            RowNumbers=zeros(TTBo.CurrentListLength,1);
            for n=1:TTBo.CurrentListLength
                if TTBo.CurrentBranchesCellArray{n}==TTBr
                    RowNumbers(n)=n;
                end
            end
            RowNumbers=nonzeros(RowNumbers)';
        end
        
 %% HAS PRIMARY BRANCHES
        function TrueFalseArray=hasThesePrimaryBranches(TTBox,CellArrayofTextTreeBranches)
            if ~isa(CellArrayofTextTreeBranches,'cell'), error('hasThesePrimaryBranches expects a cell array as the second argument'), end
            TrueFalseArray=false(1,length(CellArrayofTextTreeBranches));
            for n=1:length(CellArrayofTextTreeBranches)
                if ~isa(CellArrayofTextTreeBranches{n},'TextTreeBranch')
                    error('The elements of the second argument need to be of class TextTreeBranch')
                end
                for k=1:length(TTBox.PrimaryBranchesCellArray)
                    if TTBox.PrimaryBranchesCellArray{k}==CellArrayofTextTreeBranches{n}
                        TrueFalseArray(n)=1;
                    end
                end
            end
        end
        
        function changeRowHeight()
        end
        
        function changeFontSize()
        end
        
        function changeIndentSize()
        end
        
        function changeListOrder()
        end
        
        function delete(TTBo)
            delete(TTBo.ParentFigure)
        end
        
        function shiftAxes(TTBo,ShiftAmount)
            ah=TTBo.Axes_h;
            ah.YLim=[ah.YLim(1)+ShiftAmount, ah.YLim(2)+ShiftAmount];
            if ah.YLim(1)<0 %don't let the scrolling go prior to 0
                spacing=ah.YLim(2)-ah.YLim(1);
                ah.YLim=[0,spacing];
            end
            %don't let the scrolling go beyond the max list length
            maxpos=(TTBo.CurrentListLength-1)*TTBo.RowHeight;
            if ah.YLim(1)>maxpos;
                spacing=ah.YLim(2)-ah.YLim(1);
                ah.YLim=[maxpos,maxpos+spacing];
            end
            TTBo.VertScrollBar.Value=1-ah.YLim(1)/maxpos;
        end
    end
    
    events
        %EventName
    end

end
        

        
