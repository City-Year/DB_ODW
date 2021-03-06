USE [ODW]
GO
/****** Object:  View [dbo].[AccountRelationship_Dupes]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AccountRelationship_Dupes]
AS
SELECT     dbo.DimAccountRelationship.AccountRelationshipID, dbo.DimAccountRelationship.Category, dbo.DimAccountRelationship.[Full Name From], 
                      dbo.DimAccountRelationship.[Full Name To], dbo.DimAccountRelationship.[Account Name no Household From], 
                      dbo.DimAccountRelationship.[Account Name no Household To], DimAccountRelationship_1.AccountRelationshipID AS CRID, 
                      DimAccountRelationship_1.Category AS Category2, DimAccountRelationship_1.[Full Name From] AS CFrom, DimAccountRelationship_1.[Full Name To] AS CTo, 
                      DimAccountRelationship_1.[Account Name no Household From] AS AFrom, DimAccountRelationship_1.[Account Name no Household To] AS ATo
FROM         dbo.DimAccountRelationship INNER JOIN
                      dbo.DimAccountRelationship AS DimAccountRelationship_1 ON dbo.DimAccountRelationship.[Full Name From] = DimAccountRelationship_1.[Full Name To] AND 
                      dbo.DimAccountRelationship.[Full Name To] = DimAccountRelationship_1.[Full Name From] AND 
                      dbo.DimAccountRelationship.[Account Name no Household From] = DimAccountRelationship_1.[Account Name no Household To] AND 
                      dbo.DimAccountRelationship.[Account Name no Household To] = DimAccountRelationship_1.[Account Name no Household From] AND 
                      dbo.DimAccountRelationship.Category = DimAccountRelationship_1.Category


GO
