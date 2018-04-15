function [ElementPosition,ElementNormal] = Projectorsetup(N,fc,Speed)
% azang = repmat(0:N)
% azang = repmat((1:N-1)*10,N-1,1);        
% r = fc./Speed.*ones(size(azang));
% r=1./fc./Speed/2

% 'Custom or frequency based?(C(custom) F(frequency based)'
% placementchoice=input(placementchoice)

% if placmentchoice=='C'
    
clear hydrophonecoordinates & i & index1 & cout 
N=input('How many sources? ')
% ang=input('What is the angle of the element %d');

% ang= ' What is the angle of element %d';

'Custom or frequency based?(1 for custom, 2 for frequency based)'
n = input('Enter a number: ');

switch n
    case 1
    
hydrophonecoordinates=(zeros(3,N))
angle=(zeros(2,N))
[m,n]=size(angle);

counter={'Please enter x coordinate','Please enter y coordinate','Please enter z coordinate'}; 
cout=1
index1=1;
i=1;
       
        while i<=numel(hydrophonecoordinates)
%             for i=1:numel(hydrophonecoordinates)
            
            if  index1>3
                index1=1;
            elseif i==numel(hydrophonecoordinates)
                disp(counter{index1})
                hydrophonecoordinates(i)=input('') 
                hydrophonecoordinates;
                
                break
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
        end
        
        while cout<=numel(angle)
            ang= ' What is the angle of element(two numbers) %d';
            str=sprintf(ang,cout)
            angle(cout)=input('')
            cout=cout+1;
                
        end            
        case 2
            
             while cout<=numel(angle)
            ang= ' What is the angle of element(two numbers) %d';
            str=sprintf(ang,cout)
            angle(cout)=input('')
            cout=cout+1;
%         end
% x = azang;
% y = azang
% z = azang

ElementPosition = [hydrophonecoordinates];
% ElementPosition = [x(:)';y(:)';z(:)'];
ElementNormal = [angle];

end