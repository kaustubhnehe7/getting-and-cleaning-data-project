## Create one R script called run_analysis.R that does the following:

## Initial setup 
## 1. Load required packages. 
## 2. Download Zip File. 
## 3. Unzip the dataset. 
require("data.table")
require("reshape2")
require("dplyr")


url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfilename <- "getdata_projectfiles.zip"
download.file(url,zipfilename)
unzip(zipfilename)

if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("reshape2")) {
  install.packages("reshape2")
}

if (!require("dplyr")) {
  install.packages("dplyr")
}



## 1. Merges the training and the test sets to create one data set.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.



# Load: activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load: data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]


# Load and process Test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(X_test) = features
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "Subject"

# Join all test data. 
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

#______________________________________________________________#

# Load and process X_train & y_train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

# Load activity data(TRAIN)
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "Subject"

# Bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data
data_all = rbind(test_data, train_data)
rm(X_test,X_train,y_test,y_train,test_data,train_data)
#############################################################################
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.

# Extract only the measurements on the mean and standard deviation for each measurement.
data_mean_stddev <- select(data_all,matches("mean|std|activity|subject"))
data_mean_stddev <- select(data_mean_stddev,-matches("angle"))


#############################################################################

id_labels   = c("Subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data_mean_stddev), id_labels)
melt_data      = melt(data_mean_stddev, id = id_labels, measure.vars = data_labels)

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, Subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")
