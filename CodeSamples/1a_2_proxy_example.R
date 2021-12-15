file_store_str <- "C:/Your/Directory/Path/Here/cubist_sample_"

input_dt <- utils::read.table(base::file(description=base::paste0(file_store_str,"input.txt")), header=T, quote="\"", sep=",")
output_dt <- utils::read.table(base::unz(description=base::paste0(file_store_str,"output.zip"),filename="cubist_sample_output.txt"), header=T, quote="\"", sep=",")

library(tidyr)
library(plyr)
library(stats)
library(Cubist)
library(purrr)

library(dplyr)
library(data.table)
library(tidyverse)

### go to server with this as parameter to SP in addition to the table parameters
uniqueIDName     <- "uniqueModelKey"
predictionName   <- "targetCashflow"
regressorSearch  <- "predictor"
committeeName    <- "committeeParameter"
thePredictionSet <- "thePredictionSpace"

getY             <- function(dt){as.numeric(unlist(dt[predictionName]))}
getX             <- function(dt){dt[colnames(dt)[grep(regressorSearch,colnames(dt))]]}
getCom           <- function(dt){as.numeric(dt[committeeName][[1]][1])}
trainCubist      <- function(dt, com = 15, extp = 90){Cubist::cubist(y = getY(dt),x = getX(dt),committees = getCom(dt),control = Cubist::cubistControl(extrapolation = extp))}
predictCubist    <- function(aModel, dt){stats::predict(aModel, newdata = getX(dt))}
purrCubist       <- function(aModel, dt){purrr::map2(aModel,dt,predictCubist)}

getNest          <- function(aDT,keyValue,newColumnName){
  nestColumns <- base::colnames(aDT)[base::colnames(aDT)!=keyValue]
  retNest <- tidyr::nest(aDT,newLabel=nestColumns)
  colnames(retNest) <- base::c(keyValue,newColumnName)
  return(retNest)
}

doJoin           <- function(aDT,bDT,byThis){dplyr::inner_join(aDT,bDT,by=byThis)}


callResult        <- function(i,o,keyValue,predictSpace){
                      stage <- base::paste0("doJoin(getNest(",base::deparse(base::substitute(i)),",'",keyValue,"','theInput'),getNest(",base::deparse(base::substitute(o)),",'",keyValue,"','",predictSpace,"'),'",keyValue,"')")
                      stage <- base::paste0('plyr::mutate(',stage,',theModel = purrr::map(theInput,trainCubist),theModelPrediction = purrCubist(theModel,',predictSpace,'))')
                      exec_string <- base::parse(text=stage)
                      result <- base::eval(exec_string)
                      return(result)
                      }

result <- callResult(input_dt,output_dt,uniqueIDName,thePredictionSet)

#outflows
summary(result[1,]$theInput[[1]]$targetCashflow)
summary(result[1,]$theModelPrediction[[1]])

#inflows
summary(result[2,]$theInput[[1]]$targetCashflow)
summary(result[2,]$theModelPrediction[[1]])