USE [BOPS2DB]
GO
/****** Object:  View [dbo].[vw_idmADSRole]    Script Date: 12/22/2008 10:23:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_idmADSRole]
AS
SELECT     dbo.Contract.EmployeeID, dbo.ADSRole.ContractID, dbo.ADSRole.ADSRoleEndDate, dbo.ADSRole.ADSRoleStartDate, dbo.ADSRole.ADSCode
FROM         dbo.ADSRole LEFT OUTER JOIN
                      dbo.Contract ON dbo.ADSRole.ContractID = dbo.Contract.ContractID


USE [BOPS2DB]
GO
/****** Object:  Table [dbo].[ADSRole]    Script Date: 12/22/2008 13:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADSRole](
	[ADSRoleID] [int] IDENTITY(1,1) NOT NULL,
	[ContractID] [int] NULL,
	[ADSCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ADSDescription] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ADSRoleStartDate] [datetime] NULL,
	[ADSRoleEndDate] [datetime] NULL,
 CONSTRAINT [PK_ADSRole] PRIMARY KEY CLUSTERED 
(
	[ADSRoleID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
USE [BOPS2DB]
GO
ALTER TABLE [dbo].[ADSRole]  WITH CHECK ADD  CONSTRAINT [FK_ADSRole_Contract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[Contract] ([ContractID])
ON DELETE CASCADE


select a.ADSRoleID, count(*)
from [dbo].[ADSRole] a
inner join [dbo].[Contract] c on c.ContractID = a.ContractID
group by a.ADSRoleID
having count(*) > 1

select a.[ADSCode]
--, IsNull(a.[ADSDescription],'') AS [ADSDescription]
, count(distinct c.EmployeeID)
from [dbo].[ADSRole] a
inner join [dbo].[Contract] c on c.ContractID = a.ContractID
group by a.[ADSCode]
--, IsNull(a.[ADSDescription],'')
having count(distinct c.EmployeeID) > 1

Select distinct ADSCode --130
, ADSDescription --154
, ADSRoleStartDate --217
, ADSRoleEndDate --224
From [dbo].[ADSRole]



select * from ADSRole
where ADSCode = 'O100004'
