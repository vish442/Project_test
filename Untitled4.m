clear hydrophonecoordinates 
N=input('How many sources? ')
hydrophonecoordinates=(zeros(3,N))
counter={'Please enter x coordinate','Please enter y coordinate','Please enter z coordinate'};   
index1=1;
i=1
adf=numel(hydrophonecoordinates)
        while i<=numel(hydrophonecoordinates)
%             for i=1:numel(hydrophonecoordinates)
            i
            if  index1>3
                index1=1;
            else
                if index1==1||2 & i==1||2
                disp(counter{index1})
                hydrophonecoordinates(i)=input('') 
                hydrophonecoordinates;
                index1=index1+1;
                i=i+1;
                
                else
                disp(counter{index1})
                hydrophonecoordinates(i)=input('')
                i=i+1;
                end
            end
         end
%         end
