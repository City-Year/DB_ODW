USE [ODW]
GO
/****** Object:  Table [dbo].[DimBiosAccountPreferences]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimBiosAccountPreferences](
	[BiosAccountPreferencesID] [int] IDENTITY(1,1) NOT NULL,
	[Received Connection ID] [varchar](18) NULL,
	[Sent Connection ID] [varchar](18) NULL,
	[Created By ID] [varchar](18) NOT NULL,
	[Created Date] [datetime] NOT NULL,
	[Record ID] [varchar](18) NOT NULL,
	[Deleted] [int] NOT NULL,
	[Last Modified By ID] [varchar](18) NOT NULL,
	[Last Modified Date] [datetime] NOT NULL,
	[Reference #] [varchar](80) NOT NULL,
	[Owner ID] [varchar](18) NOT NULL,
	[Account] [varchar](18) NULL,
	[Active?] [int] NOT NULL,
	[Affiliation] [varchar](255) NULL,
	[Archive?] [int] NOT NULL,
	[Availability] [varchar](255) NULL,
	[Category] [varchar](255) NULL,
	[Code Value] [varchar](255) NULL,
	[Comments] [varchar](255) NULL,
	[Contact] [varchar](18) NULL,
	[End Date] [datetime] NULL,
	[External ID] [varchar](255) NULL,
	[Geography] [varchar](255) NULL,
	[Maximum Shift Length] [decimal](4, 2) NULL,
	[Role] [varchar](255) NULL,
	[Skills] [varchar](255) NULL,
	[Start Date] [datetime] NULL,
	[Status] [varchar](255) NULL,
	[Subcategory] [varchar](255) NULL,
	[Subtype] [varchar](255) NULL,
	[Type] [varchar](255) NULL,
	[Value] [varchar](255) NULL,
	[Record Type ID] [varchar](18) NULL,
	[System Modstamp] [datetime] NOT NULL,
 CONSTRAINT [PK_DimBiosAccountPreferences] PRIMARY KEY CLUSTERED 
(
	[BiosAccountPreferencesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
