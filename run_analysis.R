# Download and read data into R
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileurl, "wearable_data.zip")
unzipped <- unzip("wearable_data.zip")

# Read in activity labels
activities <- read.table(unzipped[1])
activities[,2] <- as.character(activities[,2])

# Read in features
features <- read.table(unzipped[2])
features[,2] <- as.character(features[,2])

# Extract only measurements on mean and std
featureswanted <- grep(".*mean.*|.*std.*", features[,2])
fw <- features[featureswanted, 2]
fw <- gsub("-mean", "Mean", fw)
fw <- gsub("-std", "Std", fw)
fw <- gsub("[-()]", "", fw)

# Classify training and test data
train <- grep("/train/", unzipped) 
test <- grep("/test/", unzipped)

# Build training set
subject_train <- read.table(unzipped[train[10]])
x_train <- read.table(unzipped[train[11]])[featureswanted]
y_train <- read.table(unzipped[train[12]])
traindata <- cbind(subject_train, x_train, y_train)

#Buid test set
subject_test <- read.table(unzipped[test[10]])
x_test <- read.table(unzipped[test[11]])[featureswanted]
y_test <- read.table(unzipped[test[12]])
testdata <- cbind(subject_test, x_test, y_test)

# Merge training and test data set
data <- rbind(traindata, testdata)

# Use descriptive activity names and label dataset with variable names
colnames(data) <- c("subject", "activity", fw)

# Create a second tidy dataset with average
# of each variable for each activity 
# and each subject
data$activity <- factor(data$activity, levels = activities[,1], labels = activities[,2])
data$subject <- as.factor(data$subject)

# Use melt function to format dataframe
install.packages("reshape2")
library(reshape2)
datamelt <- melt(data, id = c("subject", "activity"))
datamean <- dcast(datamelt, subject + activity ~ variable, mean)

# Write table to file called tidy.txt
write.table(datamean, "tidy.txt", row.names = FALSE, quote = FALSE)