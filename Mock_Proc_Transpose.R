# This function mimics one of the features of SAS's PROC transpose function:
# allowing the user to do a group_by statement without aggregating the data
# producing a dataframe
#where each row represents one of the  groups that is produced, and the columns 
#represent an observation in one of those groups.
library(dplyr)

transp <- function(input,uniq_var,compare_var,transposed_column_names = 'measurement'){
  if(class(input[,uniq_var]) == "factor"){
    print("hello")
    input[uniq_var] = sapply(input[uniq_var],as.character)
    print('goodbye')
    print(input)
  }
  #' input is the dataframe/data.table that you want to perform the operation on, uniq_var is the variable that you are groupying by, compare_var is the variable that is being measured in each of the groups, and transposed_colum_names is just an optional string for the user to call each of their columns (will be concatenated with an observation number, i.e. if you input 'distance', it will name the observations  'distance_1','distance_2','distance_3'...ect.)
  #list_df <- input %>% arrange(group_by(input[,uniq_var]) %>% do(newcol = t(.[compare_var])))
  list_df <- input %>% group_by(input[,uniq_var]) %>% do(newcol = t(.[compare_var]))
  # it gets us the aggregates we want, BUT all of our columns are stored in a list 
  # instead of in separate columns.... so we need to create a new dataframe with the dimensions 
  # rows = the number of unique values that we are "grouping" by, noted here by uniq_var and the number of columns will be 
  # the maximum number of observations that are assigned to one of those groups.
  
  # so first we will create the skeleton of the matrix, and then use a user defined function 
  # to fill it with the correct values 
  new_df <- matrix(rep(NA,(max(count(input,input[,uniq_var])[,2])*dim(list_df)[1])),nrow = dim(list_df)[1])
  new_df <- data.frame(new_df)
  new_df <- cbind(list_df[,1],new_df)
  # i am writing a function inside of a function becuase for loops can take a while 
  # when doing operaitons on multiple columns of a dataframe
  func2 <- function(input,thing = new_df){
    
    # here, we have a slightly easier case when we have the maximum number of children 
    # assigned to a household.
    # we subtract 1 from the number of columns because the first column holds the value of the 
    # unique value we are looking at, so we don't count it 
    
    if(length(input[2][[1]])==dim(thing)[2]-1){
      # we set the row corresponding to the specific unique value specified in our list_df of aggregated values
      # equal to the de-aggregated values, so that you have a column for each value like in PROC Transpose. 
      thing[which(thing[,1]==input[1]),2:ncol(thing)]= input[2][[1]]
      
      #new_df[which(new_df[,1]==input[1]),2:ncol(new_df)]= input[2][,1][[1]][[1]]
    }else{
      thing[which(thing[,1]==input[1]),2:(1+length(input[2][[1]]))]= input[2][[1]]
    }
    # if you're wondering why I have to use so many []'s it's because our list_df has 1 column 
    # of unique identifiers and the other column is actually a column of dataframes
    # each of which only has 1 row and 1 column, and that element is a list of the transposed values 
    # that we want to add to our new dataframe 
    # so essentially the first bracket 
    
    return(thing[which(thing[,1]==input[1]),])
  }
  
  quarter_final_output <- apply(list_df,1,func2)
  semi_final_output <- data.frame(matrix(unlist(quarter_final_output),nrow = length(quarter_final_output),byrow = T))
  #return(apply(list_df,1,func2))
  # this essentially names the columns according to the column names that a user would typically specify 
  # in a proc transpose. 
  name_trans <- function(trans_var=transposed_column_names,uniq_var = uniq_var,df){
    #print(trans_var)
    colnames(df)[1] = colnames(input[uniq_var])
    colnames(df)[2:length(colnames(df))] = c(paste0(trans_var,seq(1,(length(colnames(df))-1),1)))
    return(df)
    
  }
  final_output <- name_trans(transposed_column_names,uniq_var,semi_final_output)
  return(final_output)
  
}