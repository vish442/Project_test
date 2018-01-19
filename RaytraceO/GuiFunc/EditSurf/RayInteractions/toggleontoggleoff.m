function toggleontoggleoff(~,~,toggletheseon,toggletheseoff)
for n=1:length(toggletheseon)
    toggletheseon{n}.Visible='on';
    if strcmpi(toggletheseon{n}.Style,'checkbox')
        if toggletheseon{n}.Value==1
            notify(toggletheseon{n},'Action')
        end
    end
end
for n=1:length(toggletheseoff)
    toggletheseoff{n}.Visible='off';
end
end
