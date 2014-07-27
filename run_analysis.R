if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

##We load the labels, names and data first.
activity_labels <- read.table("./activity_labels.txt")[,2]

features <- read.table("./features.txt")[,2]

extract_features <- grepl("mean|std", features)

##Then load and process X_test & y_test data.
X_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")

names(X_test) = features

##In order to take the measurements on the mean and standard deviation for each measurement.
X_test = X_test[,extract_features]

##We load the activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

##Bind the data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

##Load X_train & y_train data.
X_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")

subject_train <- read.table("./train/subject_train.txt")

names(X_train) = features

##Again, re-extract the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,extract_features]

##Data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

##Data bind
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

##Train & Test data merge
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

##Finally apply the mean function to the dataset
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")