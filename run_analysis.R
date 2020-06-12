library(data.table)
library(reshape2)

# Download and unzip the data file
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- getwd()
download.file(url, file.path(dir, "data.zip"))
unzip(zipfile = "data.zip")

# Load activity labels and features
activityLabels <- fread(file.path(dir, "UCI HAR Dataset/activity_labels.txt"), 
                        col.names = c("classLabels", "activityName"))
features <- fread(file.path(dir, "UCI HAR Dataset/features.txt"),
                   col.names = c("index", "featureNames"))

# Select needed features
neededFeatures <- grep("mean\\()|std\\()", features[, featureNames])
feat <- features[neededFeatures, featureNames]
feat <- gsub("[()]", "", feat)

# Load train data
train <- fread(file.path(dir, "UCI HAR Dataset/train/X_train.txt"))[, neededFeatures, with=FALSE]
setnames(train, colnames(train), feat)
trainActivities <- fread(file.path(dir, "UCI HAR Dataset/train/Y_train.txt"),
                         col.names = "Activity")
trainSubjects <- fread(file.path(dir, "UCI HAR Dataset/train/subject_train.txt"),
                       col.names = "SubjectNum")
train <- cbind(train, trainActivities, trainSubjects)

# Load test data
test <- fread(file.path(dir, "UCI HAR Dataset/test/X_test.txt"))[, neededFeatures, with=FALSE]
setnames(test, colnames(test), feat)
testActivities <- fread(file.path(dir, "UCI HAR Dataset/test/Y_test.txt"),
                         col.names = "Activity")
testSubjects <- fread(file.path(dir, "UCI HAR Dataset/test/subject_test.txt"),
                       col.names = "SubjectNum")
test <- cbind(test, testActivities, testSubjects)

# Merge data
merged <- rbind(train, test)

# Copy of merged data
copy <- merged

# Convert classLabels to activityName
copy[["Activity"]] <- factor(copy[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

copy[["SubjectNum"]] <- as.factor(copy[, SubjectNum])
copy <- reshape2::melt(data = copy, id = c("SubjectNum", "Activity"))
copy <- reshape2::dcast(data = copy, SubjectNum + Activity ~ variable, fun.aggregate = mean)

fwrite(copy, "tidyData.txt")
write.table(copy, "tidyData1.txt", row.names = FALSE)
