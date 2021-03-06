USE [ODW]
GO
/****** Object:  Table [dbo].[DimBiosAccountSalutation]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimBiosAccountSalutation](
	[BiosAccountSalutationID] [int] IDENTITY(1,1) NOT NULL,
	[Received Connection ID] [varchar](18) NULL,
	[Sent Connection ID] [varchar](18) NULL,
	[Created By ID] [varchar](18) NULL,
	[Created Date] [datetime] NULL,
	[Record ID] [varchar](18) NULL,
	[Deleted] [int] NULL,
	[Last Activity Date] [datetime] NULL,
	[Last Modified By ID] [varchar](18) NULL,
	[Last Modified Date] [datetime] NULL,
	[Salutation Name] [varchar](80) NULL,
	[Owner ID] [varchar](18) NULL,
	[Account] [varchar](18) NULL,
	[Archive?] [int] NULL,
	[Contact] [varchar](18) NULL,
	[Inside Salutation] [varchar](255) NULL,
	[Preferred Salutation?] [int] NULL,
	[Salutation Description] [varchar](255) NULL,
	[Salutation Line 1] [varchar](255) NULL,
	[Salutation Line 2] [varchar](255) NULL,
	[Salutation Line 3] [varchar](255) NULL,
	[Salutation Type] [varchar](255) NULL,
	[System Modstamp] [datetime] NULL,
 CONSTRAINT [PK_DimBiosAccountSalutation] PRIMARY KEY CLUSTERED 
(
	[BiosAccountSalutationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
) ON [INDEXES]

GO
