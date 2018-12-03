Making Network tempalte for subjects.

%This code uses a connectivity matrices, a template connectivity matrix, and label file, to try to assingn
%specific networks to the nodes of an individual.

There are several ways to do this:

1)If you have a correlation matrix for you subject and a template, this code will calculate the correlation between each a vector of correlations for greyordinate to every other greyodrinate.

2) Template matching.  This code will take a template of various networks and use caluculate an eta squared value against all other greyordinates.



Severeal parameters are currrently specified at the beginning.  These will need to converted into being passed in as arguments at a later dates. 

%Currently this code only supports dconns.  Pconns are in beta.

The input arguments are: and input cifti and an output name.

data_type = 'dense'; % type dense or parcellated
method = 'template_matching'; %select 'correlate' 'useeta' or 'template_matching'.
eta_method = 'average'; % eta_value
make_cifti_from_results =1; %output results as a viewable cifti.
plot_data = 0; ROI = 50;
include_self = 0; % remove self from correlation (e.g. remove 1s from diagnoal when calculating correlation.
distribute_job =0; % Not supported. For use with dconns.  If distribute jobs =1, the code will attempt to split the 8.3bn comparisons (correlations or eta-squared) across 20 nodes. NOTE: Currently only tested with correlations.
transform_data = 'Convert_FisherZ_to_r'; %cases:'Convert_FisherZ_to_r' or 'Convert_r_to_Pearons' or 'Convert_to_Zscores' %Used for template matching.  If your template values are in Pearson's r, but your data is Fisher Z transformed, this will convert your data from Fisher Z to Pearson. 

outputs are two files: 
eta squared value for each greyodrinate to specified network (.mat file).
Second output file is the network assingment associated with maximum eta value.

