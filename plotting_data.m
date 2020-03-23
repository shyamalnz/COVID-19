%%


countries = unique(covid_location(:,4));


countries_data = nan(length(countries),size(covid_data,2),3);

for n = 1 : length(countries)
    
    
    i_use = strcmp(countries{n},covid_location(:,4));
    
    d_temp = covid_data(i_use,:,:);
    
    countries_data(n,:,:) = nansum(d_temp,1);
    
end

%

i_nsw = find(strcmp(covid_location(:,3),'New South Wales'));

countries_data = cat(1,covid_data(i_nsw,:,:),countries_data);
countries = [covid_location(i_nsw,3);countries];

%
summary_sta_max = squeeze(max(countries_data,[],2));

summary_sta_min = squeeze(min(countries_data,[],2));
%%
covid_date_zero = min(covid_dates);
dates_use = covid_dates - covid_date_zero;

%%
dates_final = [-30:60]';
zero_threshold = 50;
keep = summary_sta_max(:,1) > zero_threshold;


wk_countries = countries(keep);
wk_data = countries_data(keep,:,:);


day_offset = nan(size(wk_countries));
wk_data_shifted = nan(size(dates_final,1),size(wk_countries,1),3);
for n = 1 : length(wk_countries)
    
    I = find(wk_data(n,:,1) >=zero_threshold,1);
    
    act_value = wk_data(n,I,1);
    if act_value > zero_threshold
        if I == 1
            I = - 10;
        else
            range = wk_data(n,I,1) - wk_data(n,I-1,1);
            error = zero_threshold - wk_data(n,I,1);
            offset_d = I + error/range;
        end
        
    else
        offset_d = I;
    end
    
    day_offset(n) = offset_d;
    
    old_data = squeeze(wk_data(n,:,:));
    new_data =  interp1(dates_use - day_offset(n),old_data,dates_final);
    wk_data_shifted(:,n,:) = new_data;
end

%%
line_width = 2;
for n = 1 : 3
    fh = figure(n+10);
    clf(fh);
    ah = axes;
    hold off
    pause(1)
    
    temp_data = wk_data_shifted(:,:,n);
    plot_data_use = diff(temp_data)./temp_data(2:end,:);
    plot_data_use = diff(temp_data);
    
    dates_plot = dates_final(2:end);
    
    plot_data_use = temp_data;
    dates_plot = dates_final;
    
    
    o_lh = plot(dates_plot,plot_data_use,'color',[0.3,0.3,0.3,0.5]);
    
    
    h = gca;
    h.YScale = 'log';
    
    if max(plot_data_use(:)) <= 1
        h.YLim = [0,max(plot_data_use(:))*1.1];
    else
        h.YLim = [1,max(plot_data_use(:))*1.2];
    end
        %h.YLim = [0,200];
    
    lh = legend(wk_countries);
    lh.Location = 'eastoutside';
    legend('off')
    hold on
    
    %
    i_it = find(strcmp(wk_countries,'Italy'));
    lh_it = plot(dates_plot,plot_data_use(:,i_it));
    lh_it.LineWidth = line_width;
    lh_it.Color = [1,0.5,0.5];
    
    i_it = find(strcmp(wk_countries,'Spain'));
    lh_it = plot(dates_plot,plot_data_use(:,i_it));
    lh_it.LineWidth = line_width;
    lh_it.Color = [1,0,0];
    
    %
    if false
    i_it = find(strcmp(wk_countries,'United Kingdom'));
    lh_it = plot(dates_plot,plot_data_use(:,i_it));
    lh_it.LineWidth = line_width;
    lh_it.Color = [1,0,1];
    i_it = find(strcmp(wk_countries,'US'));
    lh_it = plot(dates_plot,plot_data_use(:,i_it));
    lh_it.LineWidth = 3;
    lh_it.Color = [0.5,0,0.5];
    
    
    %
    i_it = find(strcmp(wk_countries,'Singapore'));
    lh_it = plot(dates_plot,plot_data_use(:,i_it));
    lh_it.LineWidth = line_width;
    lh_it.Color = [1,0.5,1];
    end
    
    %
    i_nsw = find(strcmp(wk_countries,'New South Wales'));
    lh_nsw = plot(dates_plot,plot_data_use(:,i_nsw));
    lh_nsw.LineWidth = line_width;
    lh_nsw.Color = [0,0,0.5];
    
    
    %
    i_australia = find(strcmp(wk_countries,'Australia'));
    lh = plot(dates_plot,plot_data_use(:,i_australia));
    lh.LineWidth = line_width;
    lh.Color = [0,0,1];
    
    i_nz = find(strcmp(wk_countries,'New Zealand'));
    if ~isempty(i_nz)
        lh_nz = plot(dates_plot,plot_data_use(:,i_nz));
        lh_nz.LineWidth = line_width;
        lh_nz.Color = [1,0,1];
    end
    
    hold off
    pause(1)
end

%%
[~,I] = sort(summary_sta_max(:,2));

countries_by_death = countries(I);