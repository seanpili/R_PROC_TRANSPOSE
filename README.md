# R_PROC_TRANSPOSE
R function for those who want to use group by and return groups without any aggregation in a dataframe, mimicking SAS's PROC Transpose statement 

For example.... 

| Patient Age   | Patient Status|
| ------------- | ------------- |
|      10       |     'sick'    |
|      20       |     'well'    |
|      30       |   'unknown'   |
|      20       |     'sick'    |
|      18       |     'well'    |
|      17       |     'well'    |
|      1        |     'well'    |
|      5        |     'well'    |
|      17       |   'unknown'   |
|      33       |     'sick'    |
|      8        |   'unknown'   |

will be turned into 

| Patient Status | Patient_1_Age | Patient_2_Age | Patient_3_Age | Patient_4_Age | Patient_5_Age |
| -------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
|     'sick'     |      10       |      20       |      33       |      <NA>     |      <NA>     |
|     'well'     |      20       |      18       |      17       |      1        |      5        |
|    'unknown'   |      30       |      17       |      8        |      <NA>     |      <NA>     |

