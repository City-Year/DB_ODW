USE [ODW]
GO
/****** Object:  Table [dbo].[DimContactRelationshipProcessed]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimContactRelationshipProcessed](
	[Contact ID] [nvarchar](250) NULL,
	[Contact From] [nvarchar](250) NULL,
	[Contact To] [nvarchar](250) NULL,
	[Account To] [nvarchar](250) NULL,
	[Relationship] [nvarchar](250) NULL,
	[RelationshipType] [nvarchar](250) NULL
) ON [INDEXES]

GO
