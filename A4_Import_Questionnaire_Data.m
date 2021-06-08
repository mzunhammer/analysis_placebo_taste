function df_questionnaire=A4_Import_Questionnaire_Data(filename)
raw=readcell(filename,'Delimiter','\t','LeadingDelimitersRule' ,'keep','TrailingDelimitersRule','keep');

raw_id=readtable(filename,'Delimiter','\t','Range','A:A');
[~,id_num]=cellfun(@(x) regexp(x,'\D*(\d+)\D*','match','tokens'),raw_id{:,:},'UniformOutput',false);

qs=struct('POMS',[],...
          'ADSk',[],...
          'STAI_G_X1',[],...
          'STAI_G_X2',[],...
          'PainSQ',[],...
          'PSQ20',[],...
          'NEO_FFI',[],...
          'PSQI',[]);
for i=1:length(raw)
   curr_Q=raw{i,2};
   if ~isempty(id_num{i})
       curr_id={str2num(id_num{i}{:}{:})};
   else
       curr_id=NaN;
   end
   curr_rawitems=[curr_id,raw(i,1:end)];
   qs.(curr_Q)=[qs.(curr_Q);curr_rawitems];    
end

q_names=fieldnames(qs);
for i=1:length(q_names)
    curr_q=q_names{i};
    curr_items=qs.(curr_q)(:,7:end);
    ms=cellfun(@(x) any(ismissing(x)), curr_items);
    curr_items(ms)={NaN}; %'Replace Missing'
    IsAllMs = all(ms,1); %drop all missing
    curr_items=curr_items(:,~IsAllMs);
    nums = cellfun(@(x) isnumeric(x), curr_items);   % true for elements of C that are numerical scalars
    IsAllNum = all(nums,1);   % true for columns of C that have only numerical scalars
    curr_items_tab=table;
    for j=1:length(IsAllNum)
        if IsAllNum(j)==1
        curr_items_tab(:,j) = array2table(cell2mat(curr_items(:,j)));
        else
        curr_items_tab(:,j) = array2table(curr_items(:,j));
        end
    end
    qs.(curr_q)=...
    [cell2table(qs.(curr_q)(:,1),'VariableNames',{'id'}),...
    cell2table(qs.(curr_q)(:,2),'VariableNames',{'id_raw'}),...
    array2table(datetime(qs.(curr_q)(:,5),'InputFormat','yyyy MM dd HH:mm:ss'),'VariableNames',{'DateTime'}),...
    curr_items_tab];
    qs.(curr_q).id=categorical(qs.(curr_q).id);
    qs.(curr_q)=qs.(curr_q)(~isundefined(qs.(curr_q).id),:);
end    

% Scoring POMS
POMS_subscales={'Tension','Depression','Anger','Vigor','Fatigue','Confusion'};
POMS_item_loading=...
array2table(...
[0	1	0	0	0	0	0	0	0	1	0	0	0	0	0	1	0	0	0	1	0	-1	0	0	0	1	1	0	0	0	0	0	0	1	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	1	0	0	0	1	0	0	0	0	1	0	0	0	1	0	0	1	0	1	0	0	0	0	0	0	0	0	1	0	0	1	1	0	0	0	0	0	0	0	1	1	0	0	1	0	0	0	0	0	0	0	0	0	1	0	0	1	1	0	0	0
0	0	1	0	0	0	0	0	0	0	0	1	0	0	0	0	1	0	0	0	0	0	0	1	0	0	0	0	0	0	1	0	1	0	0	0	0	0	1	0	0	1	0	0	0	0	1	0	0	0	0	1	1	0	0	0	1	0	0	0	0	0	0	0	0
0	0	0	0	0	0	1	0	0	0	0	0	0	0	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	1	0	0	0	1	0	0	1	0	0
0	0	0	1	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	1	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	-1	0	0	0	0	1	0	0	0	0	1	0]',...
'VariableNames',POMS_subscales);

qs.POMS= [qs.POMS,array2table(qs.POMS{:,4:end}*POMS_item_loading{:,:},'VariableNames',POMS_subscales)];
qs.POMS.Tension=qs.POMS.Tension+4; qs.POMS.Confusion=qs.POMS.Confusion+4;
qs.POMS.Total_Mood_Disturbance=sum(qs.POMS{:,{'Tension','Depression','Anger','Fatigue','Confusion'}},2)-qs.POMS{:,{'Vigor'}};


% Scoring ADSk
qs.ADSk.Score=...
sum([qs.ADSk.Var1,...
qs.ADSk.Var2,...
qs.ADSk.Var3,...
qs.ADSk.Var4,...
qs.ADSk.Var5,...
qs.ADSk.Var6,...
qs.ADSk.Var7,...
qs.ADSk.Var8,...
qs.ADSk.Var8*(-1)+3,...
qs.ADSk.Var10,...
qs.ADSk.Var11,...
qs.ADSk.Var12*(-1)+3,...
qs.ADSk.Var13,...
qs.ADSk.Var14,...
qs.ADSk.Var15],2);

% Scoring STAIs
qs.STAI_G_X1.Score=sum(qs.STAI_G_X1{:,strncmpi(qs.STAI_G_X1.Properties.VariableNames,'Var',3)},2);
qs.STAI_G_X2.Score=sum(qs.STAI_G_X2{:,strncmpi(qs.STAI_G_X2.Properties.VariableNames,'Var',3)},2);

% Scoring Pain Catastrophising Scale
% 1.Stellen Sie sich vor, Sie sto&szlig;en sich das Schienbein heftig an einer harten Kante, z.B. an der Kante eines Couchtischs aus Glas.
% 2.Stellen Sie sich vor, Sie verbrennen sich die Zunge an einem sehr hei&szlig;en Getr&auml;nk.
% 3. Stellen Sie sich vor, Sie haben nach k&ouml;rperlicher Bet&auml;tigung einen leichten Muskelkater.
% 4.Stellen Sie sich vor, Sie klemmen sich einen Finger in einer Schublade.
% 5.Stellen Sie sich vor, sie duschen mit lauwarmem Wasser.
% 6.Stellen Sie sich vor, Sie haben einen leichten Sonnenbrand auf den Schultern.
% 7.Stellen Sie sich vor, Sie haben bei einem Sturz vom Fahrrad ein Knie aufgesch&uuml;rft.
% 8.Stellen Sie sich vor, Sie bei&szlig;en sich beim Essen aus Versehen heftig auf die Zunge oder die Wange.
% 9.Stellen Sie sich vor, Sie laufen mit blo&szlig;en F&uuml;&szlig;en &uuml;ber einen k&uuml;hlen Fliesenboden.
% 10Stellen Sie sich vor, Sie haben eine kleine Verletzung am Finger und bringen aus Versehen Zitronensaft in die Wunde.
% 11Stellen Sie sich vor, Sie stechen sich die Fingerspitze am Dorn einer Rose.
% 12Stellen Sie sich vor, Sie stecken die blo&szlig;en H&auml;nde f&uuml;r einige Minuten in den Schnee oder bringen Sie l&auml;nger mit Schnee in Kontakt, zum Beispiel beim Formen von Schneeb&auml;llen.
% 13Stellen Sie sich vor, Sie sch&uuml;tteln jemandem die Hand, der einen normalen H&auml;ndedruck hat.
% 14Stellen Sie sich vor, sie sch&uuml;tteln jemandem die Hand, der einen sehr kr&auml;ftigen H&auml;ndedruck hat.
% 15Stellen Sie sich vor, Sie fassen aus Versehen einen hei&szlig;en Topf an den genauso hei&szlig;en Henkeln an, um ihn hochzuheben.
% 16Stellen Sie sich vor, Sie tragen Sandalen und jemand tritt Ihnen mit einem schwerem Schuh auf den Fu&szlig;.
% 17Stellen Sie sich vor, Sie sto&szlig;en sich den Ellenbogen an einer Tischkante ("Musikantenknochen").
qs.PainSQ.TotalScore=mean(qs.PainSQ{:,{'Var1','Var2','Var3','Var4','Var6','Var7','Var8','Var10','Var11','Var12','Var14','Var15','Var16','Var17'}},2);
qs.PainSQ.SumNonPainfulScore=sum(qs.PainSQ{:,{'Var5','Var9','Var13'}},2);


% Scoring Perceived-Stress Questionnaire (20-item version)
psq20_labels={'Sie fühlen sich ausgeruht','PSQ01';'Sie haben das Gefühl, dass zu viele Forderungen an Sie gestellt werden','PSQ02';'Sie haben zuviel zu tun','PSQ04';'Sie haben das Gefühl, Dinge zu tun, die Sie wirklich mögen','PSQ07';'Sie fürchten, Ihre Ziele nicht erreichen zu können','PSQ09';'Sie fühlen sich ruhig','PSQ10';'Sie fühlen sich frustriert','PSQ12';'Sie sind voller Energie','PSQ13';'Sie fühlen sich angespannt','PSQ14';'Ihre Probleme scheinen sich aufzutürmen','PSQ15';'Sie fühlen sich gehetzt','PSQ16';'Sie fühlen sich sicher und geschützt','PSQ17';'Sie haben viele Sorgen','PSQ18';'Sie haben Spaß','PSQ21';'Sie haben Angst vor der Zukunft','PSQ22';'Sie sind leichten Herzens','PSQ25';'Sie fühlen sich mental erschöpft','PSQ26';'Sie haben Probleme, sich zu entspannen','PSQ27';'Sie haben genug Zeit für sich','PSQ29';'Sie fühlen sich unter Termindruck','PSQ30'};
psq_20_labels_tab=[table([1:length(psq20_labels)]','VariableNames',{'Item'}),cell2table(psq20_labels)];
qs.PSQ20.Properties.VariableNames(strncmpi(qs.PSQ20.Properties.VariableNames,'Var',3))=psq_20_labels_tab.psq20_labels2;
psq_scoring=cell2table(...
{'PSQ09','Sorgen',1,0
'PSQ12','Sorgen',1,0
'PSQ15','Sorgen',1,0
'PSQ18','Sorgen',1,0
'PSQ22','Sorgen',1,0
'PSQ01','Anspannung',-1,5
'PSQ10','Anspannung',-1,5
'PSQ14','Anspannung',1,0
'PSQ26','Anspannung',1,0
'PSQ27','Anspannung',1,0
'PSQ07','Freude',1,0
'PSQ13','Freude',1,0
'PSQ17','Freude',1,0
'PSQ21','Freude',1,0
'PSQ25','Freude',1,0
'PSQ02','Anforderungen',1,0
'PSQ04','Anforderungen',1,0
'PSQ16','Anforderungen',1,0
'PSQ29','Anforderungen',-1,5
'PSQ30','Anforderungen',1,0
'PSQ01','Gesamt',-1,5
'PSQ02','Gesamt',1,0  
'PSQ04','Gesamt',1,0  
'PSQ07','Gesamt',-1,5  
'PSQ09','Gesamt',1,0  
'PSQ10','Gesamt',-1,5  
'PSQ12','Gesamt',1,0  
'PSQ13','Gesamt',-1,5  
'PSQ14','Gesamt',1,0  
'PSQ15','Gesamt',1,0  
'PSQ16','Gesamt',1,0  
'PSQ17','Gesamt',-1,5  
'PSQ18','Gesamt',1,0  
'PSQ21','Gesamt',-1,5  
'PSQ22','Gesamt',1,0  
'PSQ25','Gesamt',-1,5  
'PSQ26','Gesamt',1,0  
'PSQ27','Gesamt',1,0  
'PSQ29','Gesamt',-1,5  
'PSQ30','Gesamt',1,0  },'VariableNames',{'ItemNo','Scale','Multi_Weight','Added_Weight'});

PSQ20_scales=unique(psq_scoring.Scale);
for i=1:length(PSQ20_scales)
    currscale=PSQ20_scales{i};
    curr_scoring_tbl=psq_scoring(strcmpi(psq_scoring.Scale,currscale),:);
    qs.PSQ20.(currscale)=...
        ((sum(...
        (qs.PSQ20{:,ismember(qs.PSQ20.Properties.VariableNames,curr_scoring_tbl.ItemNo)}...
        .*curr_scoring_tbl.Multi_Weight')...
        +curr_scoring_tbl.Added_Weight',2)...
        ./length(unique(curr_scoring_tbl.ItemNo))...
        -1)./3).*100;
end

%Scoring NEO-FFI
NEOFFI_scoring=cell2table(...
{
'Var1','NEOFFI_Neuroticism'
'Var6','NEOFFI_Neuroticism'
'Var11','NEOFFI_Neuroticism'
'Var16','NEOFFI_Neuroticism'
'Var21','NEOFFI_Neuroticism'
'Var26','NEOFFI_Neuroticism'
'Var31','NEOFFI_Neuroticism'
'Var36','NEOFFI_Neuroticism'
'Var41','NEOFFI_Neuroticism'
'Var46','NEOFFI_Neuroticism'
'Var51','NEOFFI_Neuroticism'
'Var56','NEOFFI_Neuroticism'
'Var2','NEOFFI_Extraversion'
'Var7','NEOFFI_Extraversion'
'Var12','NEOFFI_Extraversion'
'Var17','NEOFFI_Extraversion'
'Var22','NEOFFI_Extraversion'
'Var27','NEOFFI_Extraversion'
'Var32','NEOFFI_Extraversion'
'Var37','NEOFFI_Extraversion'
'Var42','NEOFFI_Extraversion'
'Var47','NEOFFI_Extraversion'
'Var52','NEOFFI_Extraversion'
'Var57','NEOFFI_Extraversion'
'Var3','NEOFFI_Openness'
'Var8','NEOFFI_Openness'
'Var13','NEOFFI_Openness'
'Var18','NEOFFI_Openness'
'Var23','NEOFFI_Openness'
'Var28','NEOFFI_Openness'
'Var33','NEOFFI_Openness'
'Var38','NEOFFI_Openness'
'Var43','NEOFFI_Openness'
'Var48','NEOFFI_Openness'
'Var53','NEOFFI_Openness'
'Var58','NEOFFI_Openness'
'Var4','NEOFFI_Agreeableness'
'Var9','NEOFFI_Agreeableness'
'Var14','NEOFFI_Agreeableness'
'Var19','NEOFFI_Agreeableness'
'Var24','NEOFFI_Agreeableness'
'Var29','NEOFFI_Agreeableness'
'Var34','NEOFFI_Agreeableness'
'Var39','NEOFFI_Agreeableness'
'Var44','NEOFFI_Agreeableness'
'Var49','NEOFFI_Agreeableness'
'Var54','NEOFFI_Agreeableness'
'Var59','NEOFFI_Agreeableness'
'Var5','NEOFFI_Conscientiousness'
'Var10','NEOFFI_Conscientiousness'
'Var15','NEOFFI_Conscientiousness'
'Var20','NEOFFI_Conscientiousness'
'Var25','NEOFFI_Conscientiousness'
'Var30','NEOFFI_Conscientiousness'
'Var35','NEOFFI_Conscientiousness'
'Var40','NEOFFI_Conscientiousness'
'Var45','NEOFFI_Conscientiousness'
'Var50','NEOFFI_Conscientiousness'
'Var55','NEOFFI_Conscientiousness'
'Var60','NEOFFI_Conscientiousness'},'VariableNames',{'ItemNo','Scale'});
        
NEOFFI_scales=unique(NEOFFI_scoring.Scale);
for i=1:length(NEOFFI_scales)
    currscale=NEOFFI_scales{i};
    curr_scoring_tbl=NEOFFI_scoring(strcmpi(NEOFFI_scoring.Scale,currscale),:);
    qs.NEO_FFI.(currscale)=...
        sum(qs.NEO_FFI{:,ismember(qs.NEO_FFI.Properties.VariableNames,curr_scoring_tbl.ItemNo)},2)/12;
end

%Scoring PSQI
PSQI_labels=cell2table(...
{'Q1', '1. Wann sind Sie während der letzten vier Wochen gewöhnlich abends zu Bett gegangen?  übliche Uhrzeit:'
'Q2', '2. Wie lange hat es während der letzten vier Wochen gewöhnlich gedauert, bis Sie nachts eingeschlafen sind? In Minuten:'
'Q3', '3. Wann sind Sie während der letzten vier Wochen gewöhnlich morgens aufgestanden? übliche Uhrzeit:'
'Q4', '4. Wie viele Stunden haben Sie während der letzten vier Wochen pro Nacht tatsächlich geschlafen? (Das muß nicht mit der Anzahl der Stunden, die Sie im Bett verbracht haben, übereinstimmen) Effektive Schlafzeit (Stunden) pro Nacht: '
'Q5a', '5a. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie nicht innerhalb von 30 Minuten einschlafen konnten?'
'Q5b', '5b. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie mitten in der Nacht oder früh morgens aufgewacht sind?'
'Q5c', '5c. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, Sie aufstehen mussten, um zur Toilette zu gehen?'
'Q5d', '5d. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie Beschwerden beim Atmen hatten.'
'Q5e', '5e. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie husten mussten oder laut geschnarcht haben?'
'Q5f', '5f. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Ihnen zu kalt war?'
'Q5g', '5g. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Ihnen zu warm war?'
'Q5h', '5h. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie schlecht geträumt hatten?'
'Q5i', '5i. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie Schmerzen hatten?'
'Q5j1', '5j1. Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, Andere Gründe? Bitte beschreiben:'
'Q5j2', '5j2. Wie oft während der letzten vier Wochen konnten Sie aus diesem Grund schlecht schlafen?'
'Q6', '6. Wie würden Sie insgesamt die Qualität Ihres Schlafes während der letzten vier Wochen beurteilen? '
'Q7', '7. Wie oft haben Sie während der letzten vier Wochen Schlafmittel eingenommen (vom Arzt verschriebene oder frei verkäufliche)?'
'Q8', '8. Wie oft hatten Sie während der letzten vier Wochen Schwierigkeiten wach zu bleiben, etwa beim Autofahren, beim Essen oder bei gesellschaftlichen Anlässen?'
'Q9', '9. Hatten Sie während der letzten vier Wochen Probleme mit genügend Schwung die üblichen Alltagsaufgaben zu erledigen?'
'Q10', '10. Schlafen Sie alleine in Ihrem Zimmer? Falls sie einen Mitbewohner oder Partner haben, fragen Sie ihn/sie bitte, ob und wie oft er/sie bei Ihnen folgendes bemerkt hat:'
'Q10a', '10a. Lautes Schnarchen'
'Q10b', '10b. Lange Atempausen während des Schlafes'
'Q10c', '10c. Zucken oder ruckartige Bewegungen der Beine während des Schlafes'
'Q10d', '10d. Nächtliche Phasen von Verwirrung oder Desorientierung während des Schlafes'
'Q10e', '10e. Text: Oder andere Formen von Unruhe während des Schlafes; bitte beschreiben:'
'Q10f', '10f. Rating: Oder andere Formen von Unruhe während des Schlafes; bitte beschreiben'},'VariableNames',{'ItemNo','Label'});

qs.PSQI.Properties.VariableNames(strncmpi(qs.PSQI.Properties.VariableNames,'Var',3))=PSQI_labels.ItemNo;

for i=1:height(qs.PSQI)
    try %qs.PSQI.Q1(i)
    Q1(i)=datetime(qs.PSQI.Q1(i),'InputFormat','H');
    catch
        try
    Q1(i)=datetime(qs.PSQI.Q1(i),'InputFormat','HH:mm');
        catch
    Q1(i)=NaT;   
        end
    end
end

qs.PSQI.Q1 =  timeofday(Q1)';
for i=1:height(qs.PSQI)
    try %qs.PSQI.Q1(i)
    Q3(i)=datetime(qs.PSQI.Q3(i),'InputFormat','H');
    catch
        try
    Q3(i)=datetime(qs.PSQI.Q3(i),'InputFormat','HH:mm');
        catch
    Q3(i)=NaT;   
        end
    end
end
qs.PSQI.Q3 =   timeofday(Q3)';

qs.PSQI.Q2scored=NaN(height(qs.PSQI),1);
qs.PSQI.Q2scored(qs.PSQI.Q2<=15)=0;
qs.PSQI.Q2scored(qs.PSQI.Q2>15 & qs.PSQI.Q2<=30)=1;
qs.PSQI.Q2scored(qs.PSQI.Q2>30 & qs.PSQI.Q2<=60)=2;
qs.PSQI.Q2scored(qs.PSQI.Q2>60)=3;
    
qs.PSQI.Q4scored=NaN(height(qs.PSQI),1);
qs.PSQI.Q4scored(qs.PSQI.Q4<5)=3;
qs.PSQI.Q4scored(qs.PSQI.Q4>=5 & qs.PSQI.Q4<=6)=2; % Used the revised scoring by Beck et al. 2004, https://www.jpsmjournal.com/article/S0885-3924(03)00493-7/pdf
qs.PSQI.Q4scored(qs.PSQI.Q4>6 & qs.PSQI.Q4<=7)=1; % as the original scoring suggested by Buysse et al. is ambiguous in this respect
qs.PSQI.Q4scored(qs.PSQI.Q4>7)=0;


time_in_bed_raw=duration(qs.PSQI.Q3)-duration(qs.PSQI.Q1);
time_in_bed=time_in_bed_raw;time_in_bed(time_in_bed_raw<0)=time_in_bed(time_in_bed_raw<0)+duration(24,00,00);
qs.PSQI.time_in_bed=hours(time_in_bed);
qs.PSQI(qs.PSQI.time_in_bed>=10 | qs.PSQI.time_in_bed<=5,{'id_raw','Q1','Q3','time_in_bed'})
qs.PSQI.sleep_efficiency=(qs.PSQI.Q4./qs.PSQI.time_in_bed)*100;

qs.PSQI.sleep_eff_scored=NaN(height(qs.PSQI),1);
qs.PSQI.sleep_eff_scored(qs.PSQI.sleep_efficiency>85)=0;
qs.PSQI.sleep_eff_scored(qs.PSQI.sleep_efficiency<=85 & qs.PSQI.sleep_efficiency>74)=1; % Used the revised scoring by Beck et al. 2004, https://www.jpsmjournal.com/article/S0885-3924(03)00493-7/pdf
qs.PSQI.sleep_eff_scored(qs.PSQI.sleep_efficiency<=74 & qs.PSQI.sleep_efficiency>=65)=2; % as the original scoring suggested by Buysse et al. is ambiguous in this respect
qs.PSQI.sleep_eff_scored(qs.PSQI.sleep_efficiency<65)=3;

qs.PSQI.Q5j2=fillmissing(qs.PSQI.Q5j2,'Constant',1)

qs.PSQI.PSQI_C1_Quality=(qs.PSQI.Q6-1); % Component 1 
qs.PSQI.PSQI_C2_Latency=ceil((qs.PSQI.Q2scored+(qs.PSQI.Q5a-1))/2);% Component 2
qs.PSQI.PSQI_C3_Duration=qs.PSQI.Q4scored;% Component 3
qs.PSQI.PSQI_C4_Efficiency=qs.PSQI.sleep_eff_scored;% Component 4
qs.PSQI.PSQI_C5_Disturbance=ceil(sum(([qs.PSQI.Q5b,qs.PSQI.Q5c,qs.PSQI.Q5d,qs.PSQI.Q5e,qs.PSQI.Q5f,qs.PSQI.Q5g,qs.PSQI.Q5h,qs.PSQI.Q5i,qs.PSQI.Q5j2]-1),2)./9);% Component 5
qs.PSQI.PSQI_C6_Medication=qs.PSQI.Q7-1; % Component 6
qs.PSQI.PSQI_C7_Dysfunction=ceil((qs.PSQI.Q8-1+qs.PSQI.Q9-1)/2);% Component 7
qs.PSQI.PSQI_Total= qs.PSQI.PSQI_C1_Quality+qs.PSQI.PSQI_C2_Latency+qs.PSQI.PSQI_C3_Duration+qs.PSQI.PSQI_C4_Efficiency+qs.PSQI.PSQI_C5_Disturbance+qs.PSQI.PSQI_C6_Medication+qs.PSQI.PSQI_C7_Dysfunction;


df_questionnaire=qs.POMS(:,{'id','DateTime','Tension','Depression','Anger','Vigor','Fatigue','Confusion','Total_Mood_Disturbance'});
df_questionnaire.Properties.VariableNames={'participant_no','Start_of_Questionnaires','POMS_Tension','POMS_Depression','POMS_Anger','POMS_Vigor','POMS_Fatigue','POMS_Confusion','POMS_Total_Mood_Disturbance'};
df_questionnaire.ADSk=qs.ADSk.Score;
df_questionnaire.STAI_G_X1=qs.STAI_G_X1.Score;
df_questionnaire.STAI_G_X2=qs.STAI_G_X2.Score;
df_questionnaire.PainSQ=qs.PainSQ.TotalScore;
df_questionnaire.PSQ20_Demands=qs.PSQ20.Anforderungen;
df_questionnaire.PSQ20_Tension=qs.PSQ20.Anspannung;
df_questionnaire.PSQ20_Joy=qs.PSQ20.Freude;
df_questionnaire.PSQ20_Worries=qs.PSQ20.Sorgen;
df_questionnaire.PSQ20_Total=qs.PSQ20.Gesamt;

df_questionnaire=outerjoin(df_questionnaire,qs.NEO_FFI,...
        'Type','left',...
        'MergeKeys',false,...
        'RightVariables',{'NEOFFI_Agreeableness', 'NEOFFI_Conscientiousness', 'NEOFFI_Extraversion', 'NEOFFI_Neuroticism','NEOFFI_Openness'},'LeftKeys','participant_no','RightKeys','id');

df_questionnaire=outerjoin(df_questionnaire,qs.PSQI,...
        'Type','left',...
        'MergeKeys',false,...
        'RightVariables',{'PSQI_C1_Quality', 'PSQI_C2_Latency', 'PSQI_C3_Duration', 'PSQI_C4_Efficiency','PSQI_C5_Disturbance','PSQI_C6_Medication','PSQI_C7_Dysfunction','PSQI_Total'},'LeftKeys','participant_no','RightKeys','id');

%% Sanity checks I: correlation Matrix for all Questionnaires
cdata=corr(df_questionnaire{:,3:end},'rows','pairwise');
xvalues = df_questionnaire.Properties.VariableNames(:,3:end);
yvalues = df_questionnaire.Properties.VariableNames(:,3:end);
h = heatmap(xvalues,yvalues,cdata,'ColorMethod','None',...
    'Colormap',cbrewer('div', 'BrBG', 9, 'cubic'));    
 
%% Sanity checks II: Multivariate Outlier Detection

%Exclude Total Scores, as these are too correlated to subscales
mahal_vars= {'POMS_Tension', 'POMS_Depression' 'POMS_Anger', 'POMS_Vigor', 'POMS_Fatigue', 'POMS_Confusion' 'ADSk', 'STAI_G_X1', 'STAI_G_X2', 'PainSQ', 'PSQ20_Demands', 'PSQ20_Tension', 'PSQ20_Joy', 'PSQ20_Worries', 'NEOFFI_Agreeableness', 'NEOFFI_Conscientiousness', 'NEOFFI_Extraversion' 'NEOFFI_Neuroticism', 'NEOFFI_Openness', 'PSQI_C1_Quality', 'PSQI_C2_Latency', 'PSQI_C3_Duration', 'PSQI_C4_Efficiency', 'PSQI_C5_Disturbance', 'PSQI_C6_Medication', 'PSQI_C7_Dysfunction'} ;
mahal_outlr_tresh=chi2inv(.999, length(mahal_vars));
%Exclude NaNs
no_nans=~any(isnan(df_questionnaire{:,mahal_vars}),2);
Y=df_questionnaire{no_nans,mahal_vars}; 
mahaldist=mahal(Y,mvnrnd(nanmean(Y),nancov(Y),10000));
df_questionnaire.MahalDist=NaN(height(df_questionnaire),1);
df_questionnaire.MahalDist(no_nans)=mahaldist;
hist(df_questionnaire.MahalDist,40)
hold on
vline(mahal_outlr_tresh)
hold off;
df_questionnaire.MahalSuspect=df_questionnaire.MahalDist>mahal_outlr_tresh;
%     mahal(Y,mvnrnd(nanmean(Y),nancov(Y),10000))
% lastwarn('')
% for i=4:width(df_questionnaire)
%     Y=df_questionnaire{~any(isnan(df_questionnaire{:,3:end}),2),3:i};
%     mahal(Y,mvnrnd(nanmean(Y),nancov(Y),10000));
%     [~, msgid] = lastwarn
%     if strcmp(msgid,'MATLAB:nearlySingularMatrix')
%         df_questionnaire.Properties.VariableNames(i)
%         return
%     end
% end
df_questionnaire(df_questionnaire.MahalSuspect,:)
%% Sanity checks III: High Ratings on non-painful Pain Sensitivity Questionnaire Items
disp('These participants likely did not read & understand the items, or have a severely disturbed concept of painfullness.')
table(qs.PainSQ.id(qs.PainSQ.SumNonPainfulScore>6),qs.PainSQ.SumNonPainfulScore(qs.PainSQ.SumNonPainfulScore>6))

end