USE [ODW]
GO
/****** Object:  Table [dbo].[DimBiosContactAddress]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimBiosContactAddress](
	[BiosContactAddressID] [int] IDENTITY(1,1) NOT NULL,
	[Received Connection ID] [varchar](18) NULL,
	[Sent Connection ID] [varchar](18) NULL,
	[Created By ID] [varchar](18) NOT NULL,
	[Created Date] [datetime] NOT NULL,
	[Record ID] [varchar](18) NOT NULL,
	[Deleted] [int] NOT NULL,
	[Last Modified By ID] [varchar](18) NOT NULL,
	[Last Modified Date] [datetime] NOT NULL,
	[Reference #] [varchar](80) NOT NULL,
	[Active?] [int] NOT NULL,
	[Additional Line 1] [varchar](255) NULL,
	[Verified Address] [varchar](18) NOT NULL,
	[Archive?] [int] NOT NULL,
	[Attention Line] [varchar](255) NULL,
	[Current City] [varchar](255) NULL,
	[Contact] [varchar](18) NOT NULL,
	[Current Country] [varchar](255) NULL,
	[Do Not Mail?] [int] NOT NULL,
	[End Date] [datetime] NULL,
	[Current Extension] [varchar](255) NULL,
	[Current Extension #] [varchar](255) NULL,
	[External ID] [varchar](255) NULL,
	[Original City] [varchar](255) NULL,
	[Original Country] [varchar](255) NULL,
	[Original Extension] [varchar](255) NULL,
	[Original Extension #] [varchar](255) NULL,
	[Original Postal Code] [varchar](255) NULL,
	[Original State/Province] [varchar](255) NULL,
	[Original Street Line 1] [varchar](255) NULL,
	[Original Street Line 2] [varchar](255) NULL,
	[Current Postal Code] [varchar](255) NULL,
	[Preferred Mailing?] [int] NOT NULL,
	[Preferred Other?] [int] NOT NULL,
	[Seasonal End Date] [datetime] NULL,
	[Seasonal End Day] [varchar](255) NULL,
	[Seasonal End Month] [varchar](255) NULL,
	[Seasonal Start Date] [datetime] NULL,
	[Seasonal Start Day] [varchar](255) NULL,
	[Seasonal Start Month] [varchar](255) NULL,
	[Selected?] [int] NOT NULL,
	[Start Date] [datetime] NULL,
	[Current State/Province] [varchar](255) NULL,
	[Current Street Line 1] [varchar](255) NULL,
	[Current Street Line 2] [varchar](255) NULL,
	[Type] [varchar](255) NULL,
	[Undeliverable Count] [decimal](18, 0) NULL,
	[Verified?] [int] NOT NULL,
	[Verified Different?] [varchar](255) NULL,
	[System Modstamp] [datetime] NOT NULL,
 CONSTRAINT [PK_DimBiosContactAddress] PRIMARY KEY NONCLUSTERED 
(
	[BiosContactAddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [INDEXES]

GO
