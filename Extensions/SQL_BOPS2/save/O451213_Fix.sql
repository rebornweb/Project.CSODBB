USE [BOPS2DB]
GO

Select *
From dbo.ADSRole
Where ADSCode like 'O451213%'
And ADSCode like '%'+char(13)+'%'
And ADSCode like '%'+char(10)+'%'

Update dbo.ADSRole
Set ADSCode = Replace( Replace( ADSCode, char(13), ''), char(10), '')
Where ADSCode like 'O451213%'
And ADSCode like '%'+char(13)+'%'
And ADSCode like '%'+char(10)+'%'

select * from dbo.idmBOPSObjectsHistory
where changeTimeStamp >= dateadd(day, -1, getdate())



