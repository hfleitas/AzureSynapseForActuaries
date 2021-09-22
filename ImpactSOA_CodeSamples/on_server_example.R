#required
install.packages('RODBC', type='binary')
install.packages('Cubist', type='binary')

#cubist example
library(Cubist)
library(RODBC)
connect <- odbcDriverConnect('driver={SQL Server};server=localhost;database=ImpactSOA;trusted_connection=true')
BostonHousing <- sqlQuery(channel=connect,query='select * from dbo.BostonHousing')

## 1 committee, so just an M5 fit:
mod1 <- cubist(x = BostonHousing[, -14], y = BostonHousing$medv)
mod1

## Now with 10 committees
mod2 <- cubist(x = BostonHousing[, -14], y = BostonHousing$medv, committees = 10)
mod2
