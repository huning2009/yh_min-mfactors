format compact;
% �����ļ���ַ
% add_data = 'G:/short_period_mf/alpha_min_stand_matlab/';
% add_resid = 'G:/short_period_mf/resid_value_min_matlab/';
add_factor_return = 'G:/short_period_mf/factor_return_min_matlab/';
% ���ս����ʼ��
data_str = struct;
% ��Ʊ����
stockList = readtable('stockList.csv');
data_str.stockcode = stockList.code;
% ����������
day_dateList = readtable('day_dateList.csv');
data_str.trade_day = day_dateList.date';
% ���׷�������
min_dateList = readtable('min_dateList.csv');
data_str.trade_min = min_dateList.datetime(7:54480)'; %��2017-01-03 09:37:00��ʼ
% ��ҵ����
% industry = readtable(fullfile(add_data,'industry.csv'));
industry = readtable('industry.csv');
industry_str = table2struct(industry,'ToScalar',true);
indus_fln = fieldnames(industry_str);
for fln=1:length(indus_fln)
    data_str.(indus_fln{fln}) = repmat(industry_str.(indus_fln{fln}),1,54474);
end
% �����������
factors_file = {'BP.csv','Beta.csv','EarnYield.csv','Growth.csv','Leverage.csv'...
                ,'Liquidity.csv','Momentum.csv','ResVol.csv','Size.csv'}';
for fn=1:length(factors_file)
    mid = kron(csvread(factors_file{fn}),ones(1,240));
    data_str.(factors_file{fn}(1:end-4)) =  mid(:,7:end);
end
clear day_dateList factors_file fln indus_fln industry...
        industry_str mid stockList min_dateList fn
% �����Ʊ����

% regerssion
data_str.fac_resid = zeros(299,54474); %���ã�����
fldname = fieldnames(data_str);
fldname = fldname(4:end,1);
for nmin =[120,180] % 1,180  %240,60
    result = zeros(191,54474);
    for n=1:191
        n
        data_str.fac_resid = zeros(299,54474);
        X_matrix = zeros(299,39);
        Fac_resid = load(strcat('alpha_',alpha_filename(n),'_resid.mat'));
        data_str.fac_resid = Fac_resid.result;
        if nmin==120
            Y = csvread(strcat('return_min_',num2str(nmin),'.csv'),7,1,[7,1,54480,299]);
        else
            Y = csvread(strcat('return_min_',num2str(nmin),'.csv'),7,2,[7,2,54480,300]);
        end
        Y = Y';
        for min_len=1:length(data_str.trade_min)
            for fn=1:length(fldname)
                X_matrix(:,fn) = data_str.(fldname{fn})(:,min_len);
            end
            b = regress(Y(:,min_len),X_matrix);
            result(n,min_len) = b(39);
        end
    end
    save(strcat(add_factor_return,'factor_return_',num2str(nmin),'.mat'),'result');
    clear result X_matrix Fac_resid Y n min_len fn 
end