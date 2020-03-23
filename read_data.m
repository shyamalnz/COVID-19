%%

data_path = [onedrive,'\COVID-19\csse_covid_19_data\csse_covid_19_time_series\'];

file_names = {
    'time_series_19-covid-Confirmed.csv'
    'time_series_19-covid-Deaths.csv'
    'time_series_19-covid-Recovered.csv'
    };

%% Organize data structures
data_size = 500;
covid_data = nan(data_size,1000,3); % all cases will be stored in here
covid_dates = [];
covid_location = cell(data_size,4); % four levels of location hieracrhy


%% Sanitise data
for j = 1 : 3
    % confirmed
    s  = importdata([data_path,file_names{j}]);
    
    textdata = s.textdata(2:end,1:2);
    date_str = s.textdata(1,5:end);
    date_num = datenum(date_str,'mm/dd/yy');
    
    data = s.data(:,3:end);
    
    if j == 1
        covid_dates = date_num;
    end
    
    for n = 1 : size(textdata,1)
        tx_w = textdata(n,:);
        new_location = cell(1,4);
        %
        new_location{4} = strtrim(tx_w{2});
        %
        if ~isempty(tx_w{1})
            split_text = strsplit(tx_w{1},',');
            if length(split_text) > 1
                tk_l = 2;
                new_location{3} = strtrim(split_text{2});
            else
                tk_l = 3;
            end
            new_location{tk_l}  = strtrim(split_text{1});
        else
            tk_l = 4;
        end
        
        %%
        index = strcmp(covid_location(:,tk_l),new_location{tk_l});
        if index == false
            index = find(isnan(covid_data(:,1)),1);
        end
        
        if all(covid_dates == date_num)
            covid_data(index,1:length(data(n,:)),j) = data(n,:);
            covid_location(index,:) = new_location;
        else
            warning("error in data")
        end
    end
end


%%
num_entries = find(isnan(covid_data(:,1,1)),1)-1;
num_dates = find(isnan(covid_data(1,:,1)),1)-1;

covid_data = covid_data(1:num_entries,1:num_dates,1:3);
covid_location = covid_location(1:num_entries,:);


%%
save('covid19.mat','covid_*');

close all
clear all