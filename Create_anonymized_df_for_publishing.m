%% Clean workspace, load packets
clear
close all

load df.mat


% Long data-frame
dfl_select={
'subject_no'
'prepost'
'treat'
'maxtime'
'rating180_full'
'aucrating_perc'
'treat_expect'
'age'
'date_of_testing'
'male'
'first_language'
'drug_administration'
'exclusion'
'treat_efficacy'
'taste_intensity'
'taste_valence'
'sumUAW'
'study'
'subject_no_numeric'
'TT_TU'};

% Values for BMI, height, weight, education, level, nutritional habits and handedness
% are binned/grouped to ensure the anonymity of study participants.
dfl_anonymized=dfl(:,dfl_select);
dfl_anonymized.bmi=round(dfl.bmi,0);
dfl_anonymized.height_in_cm=round(dfl.height_in_cm/2)*2;
dfl_anonymized.body_weight_in_kg=round(dfl.body_weight_in_kg/2)*2;

dfl_anonymized.level_of_education=dfl.level_of_education;
dfl_anonymized.level_of_education(strcmp(dfl_anonymized.level_of_education,'higher_education_entrance_qualification'))={'higher_edu_entrance_qual_or_secondary_edu'};
dfl_anonymized.level_of_education(strcmp(dfl_anonymized.level_of_education,'secondary_education_level'))={'higher_edu_entrance_qual_or_secondary_edu'};

dfl_anonymized.nutrition=dfl.nutrition;
dfl_anonymized.nutrition(strcmp(dfl_anonymized.nutrition,'vegan'))={'vegetarian_or_vegan'};
dfl_anonymized.nutrition(strcmp(dfl_anonymized.nutrition,'vegetarian'))={'vegetarian_or_vegan'};

dfl_anonymized.handedness=dfl.handedness;
dfl_anonymized.handedness(strcmp(dfl_anonymized.handedness,'both'))={'left_or_both'};
dfl_anonymized.handedness(strcmp(dfl_anonymized.handedness,'left'))={'left_or_both'};

% Wide data-frame
dfw_select={
'subject_no'
'prepost'
'treat'
'maxtime_pre'
'maxtime_post'
'rating180_full_pre'
'rating180_full_post'
'aucrating_perc_pre'
'aucrating_perc_post'
'treat_expect_post'
'age'
'date_of_testing'
'male'
'first_language'
'drug_administration'
'exclusion'
'treat_efficacy_post'
'taste_intensity_post'
'taste_valence_post'
'sumUAW_post'
'study'
'TT_TU'};

dfw_anonymized=dfw(:,dfw_select);
dfw_anonymized.bmi=round(dfw.bmi,0);
dfw_anonymized.height_in_cm=round(dfw.height_in_cm/2)*2;
dfw_anonymized.body_weight_in_kg=round(dfw.body_weight_in_kg/2)*2;

dfw_anonymized.level_of_education=dfw.level_of_education;
dfw_anonymized.level_of_education(strcmp(dfw_anonymized.level_of_education,'higher_education_entrance_qualification'))={'higher_edu_entrance_qual_or_secondary_edu'};
dfw_anonymized.level_of_education(strcmp(dfw_anonymized.level_of_education,'secondary_education_level'))={'higher_edu_entrance_qual_or_secondary_edu'};

dfw_anonymized.nutrition=dfw.nutrition;
dfw_anonymized.nutrition(strcmp(dfw_anonymized.nutrition,'vegan'))={'vegetarian_or_vegan'};
dfw_anonymized.nutrition(strcmp(dfw_anonymized.nutrition,'vegetarian'))={'vegetarian_or_vegan'};

dfw_anonymized.handedness=dfw.handedness;
dfw_anonymized.handedness(strcmp(dfw_anonymized.handedness,'both'))={'left_or_both'};
dfw_anonymized.handedness(strcmp(dfw_anonymized.handedness,'left'))={'left_or_both'};

dfl=dfl_anonymized;
dfw=dfw_anonymized;

save('df_for_publishing.mat','dfl','dfw')