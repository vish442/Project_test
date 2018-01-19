classdef TextTreeBranch < handle %this class holds information pretty much, it doesn't display it
    properties
        String %The string that is displayed
        StringCanBeChanged=true; %Boolean T/F
        CellArrayOfAllImmediateParents={}; %cell array containing all IMMEDIATE parents (not grandparents etc) - this allows a single TextTreeBranch object to be placed into one or more TextTreeBoxes or as a child to one or more TextTreeBranches
        ChildrenBranches={}; %cell array of the children TextTreeBranch handles. The same children will appear for all
        isSelected=false; %Boolean T/F - indicating if the branch is selected (highlighted)
        isExpanded=true; %Boolean T/F - determines if this branch shows the children branches under it when drawn
        isChecked=true;  %Boolean T/F - indicating the checkmark status of the checkbox
        hasCheckbox %Boolean T/F
        hasChildren=false; %Boolean T/F
        FullyExpandedLineLength %integer value # of lines when fully expanded, with all children and children's children, etc.
        UIContextMenu
        RepresentedObjectHndl
        
    end
    
    methods
%% CREATOR function 
        function TTBr=TextTreeBranch(str,hasacheckbox)
            if nargin==0
                TTBr.String='nothing';
                TTBr.hasCheckbox=1;
            elseif nargin==1
                %check that the inputs are correct-------
                if ~isa(str,'char'), error('TextTreeBranch expects a string as the first argument'), end
                TTBr.String=str;
                TTBr.hasCheckbox=1;
            else
                %check that the inputs are correct-------
                if ~isa(str,'char'), error('TextTreeBranch expects a string as the first argument'), end
                if ~isa(hasacheckbox,'char'), error('TextTreeBranch expects a string ''yes'' or ''no'' as the 2nd argument'), end
                if strcmpi(hasacheckbox,'yes'), TTBr.hasCheckbox=1; else TTBr.hasCheckbox=0; end
                TTBr.String=str;
            end
        end
        
%% ADD CHILDREN/PARENTS
        function addChildrenBranches(TTBr,childrenTextTreeBranchCellArray)
            if size(childrenTextTreeBranchCellArray,1)~=1, childrenTextTreeBranchCellArray=childrenTextTreeBranchCellArray'; end %flip if not long array
            if ~isa(childrenTextTreeBranchCellArray,'cell'), error('addChildrenBranches expects a cell array as the second argument'), end
            for n=1:length(childrenTextTreeBranchCellArray)
                if ~isa(childrenTextTreeBranchCellArray{n},'TextTreeBranch')
                    error('All elements of the second argument need to be of class TextTreeBranch')
                end
            end
            TTBr.hasChildren=1;
            TTBr.ChildrenBranches=[TTBr.ChildrenBranches,childrenTextTreeBranchCellArray];
            removeChildDuplicates(TTBr);
            for n=1:length(childrenTextTreeBranchCellArray)
                if ~hasTheseParents(childrenTextTreeBranchCellArray{n},{TTBr})
                    addParentBranches(childrenTextTreeBranchCellArray{n},{TTBr})
                end
            end
        end
        
        function addParentBranches(TTBr,parentTextTreeBranchCellArray)
            if ~isa(parentTextTreeBranchCellArray,'cell'), error('addParentBranches expects a cell array as the second argument'), end
            for n=1:length(parentTextTreeBranchCellArray)
                if ~isa(parentTextTreeBranchCellArray{n},'TextTreeBranch')
                    error('All elements of the second argument need to be of class TextTreeBranch or TextTreeBox')
                end
            end
            TTBr.CellArrayOfAllImmediateParents=[TTBr.CellArrayOfAllImmediateParents,parentTextTreeBranchCellArray];
            removeParentDuplicates(TTBr);
            for n=1:length(parentTextTreeBranchCellArray)
                if ~hasTheseChildren(parentTextTreeBranchCellArray{n},{TTBr})
                    addChildrenBranches(parentTextTreeBranchCellArray{n},{TTBr})
                end
            end
        end
        
        function addParentBoxes(TTBr,parentTextTreeBoxCellArray)
            if ~isa(parentTextTreeBoxCellArray,'cell'), error('addParentBoxes expects a cell array as the second argument'), end
            for n=1:length(parentTextTreeBoxCellArray)
                if ~isa(parentTextTreeBoxCellArray{n},'TextTreeBox')
                    error('All elements of the second argument need to be of class TextTreeBranch or TextTreeBox')
                end
            end
            TTBr.CellArrayOfAllImmediateParents=[TTBr.CellArrayOfAllImmediateParents,parentTextTreeBoxCellArray];
            removeParentDuplicates(TTBr);
            for n=1:length(parentTextTreeBoxCellArray)
                if ~hasThesePrimaryBranches(parentTextTreeBoxCellArray{n},{TTBr})
                    addPrimaryBranches(parentTextTreeBoxCellArray{n},{TTBr})
                end
            end
        end
        

        
%% REMOVE CHILDREN/PARENTS
        function removeChildrenBranches(TTBr,childrenTextTreeBranchCellArray)
            if ~isa(childrenTextTreeBranchCellArray,'cell'), error('removeChildrenBranches expects a cell array as the second argument'), end
            keepers=true(1,length(TTBr.ChildrenBranches));
            for n=1:length(TTBr.ChildrenBranches)
                for m=1:length(childrenTextTreeBranchCellArray)
                    if TTBr.ChildrenBranches{n}==childrenTextTreeBranchCellArray{m}
                        if hasTheseParents(TTBr.ChildrenBranches{n},{TTBr})
                            temp=TTBr.ChildrenBranches{n};
                            TTBr.ChildrenBranches{n}={};%remove the child first to avoid infinite looping between the two removal functions
                            removeParentBranches(temp,{TTBr});
                        end
                        keepers(n)=0;
                    end
                end
            end
            TTBr.ChildrenBranches=TTBr.ChildrenBranches(keepers);
            if isempty(TTBr.ChildrenBranches)
                TTBr.hasChildren=0;
            end
        end
        
        function removeAllChildrenBranches(TTBr)
            temp=TTBr.ChildrenBranches;
            TTBr.ChildrenBranches={};
            for n=1:length(temp)
                removeParentBranches(temp{n},{TTBr});
            end
        end
        
        function removeParentBranches(TTBr,ParentTextTreeBranchCellArray)
            if ~isa(ParentTextTreeBranchCellArray,'cell'), error('removeParentBranches expects a cell array as the second argument'), end
            keepers=true(1,length(TTBr.CellArrayOfAllImmediateParents));
            for n=1:length(TTBr.CellArrayOfAllImmediateParents)
                for m=1:length(ParentTextTreeBranchCellArray)
                    if TTBr.CellArrayOfAllImmediateParents{n}==ParentTextTreeBranchCellArray{m}
                        if hasTheseChildren(TTBr.CellArrayOfAllImmediateParents{n},{TTBr})
                            temp=TTBr.CellArrayOfAllImmediateParents{n};
                            TTBr.CellArrayOfAllImmediateParents{n}={};%remove the parent first to avoid infinite looping between the two removal functions
                            removeChildrenBranches(temp,{TTBr});
                        end
                        keepers(n)=0;
                    end
                end
            end
            TTBr.CellArrayOfAllImmediateParents=TTBr.CellArrayOfAllImmediateParents(keepers);
        end
        
        function removeAllParents(TTBr)
            temp=TTBr.CellArrayOfAllImmediateParents;
            TTBr.CellArrayOfAllImmediateParents={};
            for n=1:length(temp)
                if isa(temp{n},'TextTreeBranch')
                    removeChildrenBranches(temp{n},{TTBr});
                else
                    removePrimaryBranches(temp{n},{TTBr});
                end
            end
        end
        
        
        function removeParentBoxes(TTBr,ParentTextTreeBoxCellArray)
            if ~isa(ParentTextTreeBoxCellArray,'cell'), error('removeParentBoxes expects a cell array as the second argument'), end
            keepers=true(1,length(TTBr.CellArrayOfAllImmediateParents));
            for n=1:length(TTBr.CellArrayOfAllImmediateParents)
                for m=1:length(ParentTextTreeBoxCellArray)
                    if TTBr.CellArrayOfAllImmediateParents{n}==ParentTextTreeBoxCellArray{m}
                        if hasThesePrimaryBranches(TTBr.CellArrayOfAllImmediateParents{n},{TTBr})
                            temp=TTBr.CellArrayOfAllImmediateParents{n};
                            TTBr.CellArrayOfAllImmediateParents{n}={};%remove the parent first to avoid infinite looping between the two removal functions
                            removePrimaryBranches(temp,{TTBr});
                        end
                        keepers(n)=0;
                    end
                end
            end
            TTBr.CellArrayOfAllImmediateParents=TTBr.CellArrayOfAllImmediateParents(keepers);
        end
%% HAS PARENTS/CHILDREN
        function TrueFalseArray=hasTheseParents(TTBr,parentTextTreeBoxOrBranchCellArray)
            if ~isa(parentTextTreeBoxOrBranchCellArray,'cell'), error('hasTheseParents expects a cell array as the second argument'), end
            TrueFalseArray=false(1,length(parentTextTreeBoxOrBranchCellArray));
            for n=1:length(parentTextTreeBoxOrBranchCellArray)
                if ~isa(parentTextTreeBoxOrBranchCellArray{n},'TextTreeBranch')&&~isa(parentTextTreeBoxOrBranchCellArray{n},'TextTreeBox')
                    error('The elements of the second argument need to be of class TextTreeBranch or TextTreeBox')
                end
                for k=1:length(TTBr.CellArrayOfAllImmediateParents)
                    if TTBr.CellArrayOfAllImmediateParents{k}==parentTextTreeBoxOrBranchCellArray{n}
                        TrueFalseArray(n)=1;
                    end
                end
            end
        end
        
        function TrueFalseArray=hasTheseChildren(TTBr,childrenTextTreeBranchCellArray)
            if ~isa(childrenTextTreeBranchCellArray,'cell'), error('hasTheseChildren expects a cell array as the second argument'), end
            TrueFalseArray=false(1,length(childrenTextTreeBranchCellArray));
            for n=1:length(childrenTextTreeBranchCellArray)
                if ~isa(childrenTextTreeBranchCellArray{n},'TextTreeBranch')
                    error('The elements of the second argument need to be of class TextTreeBranch')
                end
                for k=1:length(TTBr.CellArrayOfAllImmediateParents)
                    if TTBr.CellArrayOfAllImmediateParents{k}==childrenTextTreeBranchCellArray{n}
                        TrueFalseArray(n)=1;
                    end
                end
            end
        end
        
%% NO DUPLICATES        
        function removeChildDuplicates(TTBr_h)
            keepers=true(1,length(TTBr_h.ChildrenBranches));
            for n=1:(length(TTBr_h.ChildrenBranches)-1)
                for m=(n+1):length(TTBr_h.ChildrenBranches)
                    if TTBr_h.ChildrenBranches{n}==TTBr_h.ChildrenBranches{m}, keepers(m)=0; end
                end
            end
            TTBr_h.ChildrenBranches=TTBr_h.ChildrenBranches(keepers);
        end
        
        function removeParentDuplicates(TTBr_h)
            keepers=true(1,length(TTBr_h.CellArrayOfAllImmediateParents));
            for n=1:(length(TTBr_h.CellArrayOfAllImmediateParents)-1)
                for m=(n+1):length(TTBr_h.CellArrayOfAllImmediateParents)
                    if TTBr_h.CellArrayOfAllImmediateParents{n}==TTBr_h.CellArrayOfAllImmediateParents{m}, keepers(m)=0; end
                end
            end
            TTBr_h.CellArrayOfAllImmediateParents=TTBr_h.CellArrayOfAllImmediateParents(keepers);
        end
        
 %%  Selection/Deselection of all - This was first put here for use with the TextTreeBox Class
 
        function selectAll(TTBr)
            for n=1:length(TTBr.ChildrenBranches)
                TTBr.ChildrenBranches{n}.isSelected=true(1);
                if TTBr.ChildrenBranches{n}.hasChildren
                    selectAll(TTBr.ChildrenBranches{n});
                end
            end
        end
        
        function deselectAll(TTBr)
            for n=1:length(TTBr.ChildrenBranches)
                TTBr.ChildrenBranches{n}.isSelected=false(1);
                if TTBr.ChildrenBranches{n}.hasChildren
                    deselectAll(TTBr.ChildrenBranches{n});
                end
            end
        end
 
 %%
       
        
        
        %if you delete the child of a treebranch then you redraw all the
        %associated parent boxes of that treebranch that are expanded all
        %the way from the top down to at least one of the treebranches.
        %You could go through and just do a redraw of the parent boxes that
        %have
        
        function TTBoxes=whichTextTreeBoxesExpandDownToThisBranch(TTBranch)
            %initialize TTboxes
            
            TTBoxes={};
            %go through the parents of TTBranch
            for n=1:length(TTBranch.CellArrayOfAllImmediateParents)
                %if any parents are TextTreeBoxes, then add those parents to
                %the list
                if isa(TTBranch.CellArrayOfAllImmediateParents{n},'TextTreeBox')
                    TTBoxes=[TTBoxes,TTBranch.CellArrayOfAllImmediateParents{n}];
                %otherwise, check that any of the parents are expanded and
                %repeat the function on them
                elseif TTBranch.CellArrayOfAllImmediateParents{n}.isExpanded
                    TTBoxes=[TTBoxes,whichTextTreeBoxesExpandDownToThisBranch(TTBranch.CellArrayOfAllImmediateParents{n})];
                end
            end
        end
                
            
            
            %go through the expanded parents of the branch
            %for each of those expanded parents
               %Test whether their parents are expanded
               %until you reach a TextTreeBox
            %
        
        
        
        function removeChildBranch(TTBr_h,childindex)
            childindex=round(re(childindex));
            if length(TTBr_h.ChildrenBranches)<childindex
                disp('no branch to delete at specified child index')
            else
                doredraw=0;
                if strcmpi(TTBr_h.isExpanded,'yes'), doredraw=1; end
                fulldelete(TTBr_h.ChildrenBranches{childindex});
                TTBr_h.ChildrenBranches(childindex)=[];
                if isempty(TTBr_h.ChildrenBranches)
                    doredraw=1;
                    delete(TTBr_h.ExpanderAxesHandle)
                    TTBr_h.isExpanded='no';
                    TTBr_h.ExpanderAxesHandle=[];
                end
                disp('just deleted child branch')
                if doredraw, drawTextTreeBox(TTBr_h.ParentTextTreeBox); end
            end
        end
        
        function addCheckbox(TTBr_h)
            if isempty(TTBr_h.CheckboxHandle)
                TTBr_h.CheckboxHandle=uicontrol(ParentBoxOrBranch.ParentAxes.Parent,'Type','checkbox','Visible','off');
                drawTextTreeBox(TTBr_h.ParentTextTreeBox);
            else
                disp('This TextTreeBranch already has a checkbox')
            end
        end
        
        function removeCheckbox(TTBr_h)
            if isempty(TTBr_h.CheckboxHandle)
                disp('There is no checkbox to remove')
            else
                delete(TTBr_h.CheckboxHandle)
                TTBr_h.CheckboxHandle=[];
                drawTextTreeBox(TTBr_h.ParentTextTreeBox);
            end
        end
        
        function delete(TTBr_h)
            notify(TTBr_h,'isBeingDeleted')
        end
    end
    
    
    
    events
        gotSelected
        gotDeselected
        StringChanged
        gotChecked
        gotUnchecked
        isBeingDeleted
    end

end