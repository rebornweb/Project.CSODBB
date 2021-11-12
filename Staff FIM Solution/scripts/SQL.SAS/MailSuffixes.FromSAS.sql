SELECT [Mailsuffix], COUNT(*) as [NumSasUsers]
  FROM [SAS2IDM_SAS2IDM_LIVE].[dbo].[AllSAS2IDMStudents]
group by Mailsuffix
order by Mailsuffix