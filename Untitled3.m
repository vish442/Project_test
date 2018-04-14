C=input('How many columns are there in P?  ');
    R=input('How many rows are there in P?  ');
    P=zeros(R:C);
    co=1; 
     
 
    ro=1;
          while co<=C && ro<=R;
              if co==1
                  P(co)=input('What is the first value of this column of P? ')
                  co=co+1;
              elseif co>1
                  P(co)=input('What is the next value of this column of P?  ')
                  co=co+1;
                  % 
              end
              ro=ro+1;
          end 
      P=P(R:C) 