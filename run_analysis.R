library(dplyr)

filename <- "getdata_dataset.zip"
## Download and unzip the dataset:
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only mean and stdev columns and change the variable names
wantedFeatures <- grep(".*mean.*|.*std.*", features[,2])
wantedFeatures.names <- features[wantedFeatures,2]
wantedFeatures.names <- gsub('-mean', 'Mean', wantedFeatures.names)
wantedFeatures.names <- gsub('-std', 'Std', wantedFeatures.names)
wantedFeatures.names <- gsub('[-()]', '', wantedFeatures.names)
wantedFeatures.names <- gsub('^(t)', 'time', wantedFeatures.names)
wantedFeatures.names <- gsub('^(f)', 'freq', wantedFeatures.names)
wantedFeatures.names <- gsub('([Gg]ravity)', 'Gravity', wantedFeatures.names)
wantedFeatures.names <- gsub('([Bb]ody[Bb]ody | [Bbody])', 'Body', wantedFeatures.names)
wantedFeatures.names <- gsub('([Gg]yro)', 'Gyro', wantedFeatures.names)
wantedFeatures.names <- gsub('AccMag', 'AccMagnitude', wantedFeatures.names)
wantedFeatures.names <- gsub('([Bb]odyaccjerkmag)', 'BodyAccJerkMagnitude', wantedFeatures.names)
wantedFeatures.names <- gsub('JerkMag', 'JerkMagnitude', wantedFeatures.names)
wantedFeatures.names <- gsub('GyroMag', 'GyroMagnitude', wantedFeatures.names)

# Load in the train and test datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[wantedFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[wantedFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

#Merge train and test and add column labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", wantedFeatures.names)

# turn Activities & Subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

#Create a second, independent tidy data set with the average of each variable for each activity and each subject. 
tidyData<-aggregate(. ~subject + activity, allData, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)