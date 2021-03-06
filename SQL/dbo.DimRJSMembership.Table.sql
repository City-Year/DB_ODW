USE [ODW]
GO
/****** Object:  Table [dbo].[DimRJSMembership]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRJSMembership](
	[Account] [varchar](18) NULL,
	[Comments] [varchar](255) NULL,
	[Received Connection ID] [varchar](18) NULL,
	[Sent Connection ID] [varchar](18) NULL,
	[Created By ID] [varchar](18) NULL,
	[Created Date] [datetime] NULL,
	[Fiscal Year] [varchar](255) NULL,
	[Record ID] [varchar](18) NULL,
	[Deleted] [int] NULL,
	[Last Activity Date] [datetime] NULL,
	[Last Modified By ID] [varchar](18) NULL,
	[Last Modified Date] [datetime] NULL,
	[Level] [varchar](255) NULL,
	[Reference #] [varchar](80) NULL,
	[Qualification Date] [datetime] NULL,
	[Site Affiliation] [varchar](255) NULL,
	[Society] [varchar](1300) NULL,
	[System Modstamp] [datetime] NULL,
	[Type] [varchar](255) NULL
) ON [PRIMARY]

GO
