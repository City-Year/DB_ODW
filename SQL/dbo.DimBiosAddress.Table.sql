USE [ODW]
GO
/****** Object:  Table [dbo].[DimBiosAddress]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimBiosAddress](
	[BiosAddressID] [int] IDENTITY(1,1) NOT NULL,
	[Received Connection ID] [varchar](18) NULL,
	[Sent Connection ID] [varchar](18) NULL,
	[Created By ID] [varchar](18) NULL,
	[Created Date] [datetime] NULL,
	[Record ID] [varchar](18) NULL,
	[Deleted] [int] NULL,
	[Last Modified By ID] [varchar](18) NULL,
	[Last Modified Date] [datetime] NULL,
	[Address Name] [varchar](80) NULL,
	[Owner ID] [varchar](18) NULL,
	[Archive?] [int] NULL,
	[Block Group] [varchar](255) NULL,
	[Block Number] [varchar](255) NULL,
	[Carrier Route] [varchar](255) NULL,
	[Census Tract] [varchar](255) NULL,
	[City] [varchar](255) NULL,
	[CMRA] [varchar](255) NULL,
	[Congressional District] [varchar](255) NULL,
	[Country] [varchar](3) NULL,
	[Country Name] [varchar](255) NULL,
	[County] [varchar](255) NULL,
	[County Number] [varchar](255) NULL,
	[Delivery Point] [varchar](255) NULL,
	[DPV] [varchar](255) NULL,
	[DPV Footnote] [varchar](255) NULL,
	[Extension] [varchar](255) NULL,
	[Extension Number] [varchar](255) NULL,
	[External ID] [varchar](255) NULL,
	[Firm] [varchar](255) NULL,
	[LACS] [varchar](255) NULL,
	[Latitude] [decimal](9, 6) NULL,
	[Longitude] [decimal](9, 6) NULL,
	[Maps] [varchar](1300) NULL,
	[Maps (Bing Url)] [varchar](255) NULL,
	[Maps (Google Url)] [varchar](255) NULL,
	[Maps (Yahoo Url)] [varchar](255) NULL,
	[PMB] [varchar](255) NULL,
	[PMB Designator] [varchar](255) NULL,
	[Post-Direction] [varchar](255) NULL,
	[Postal Code] [varchar](255) NULL,
	[Pre-Direction] [varchar](255) NULL,
	[State] [varchar](255) NULL,
	[State Number] [varchar](255) NULL,
	[Street Address] [varchar](1300) NULL,
	[Street Line 1] [varchar](255) NULL,
	[Street Line 2] [varchar](255) NULL,
	[Street Name] [varchar](255) NULL,
	[Street Number] [varchar](255) NULL,
	[Street Type] [varchar](255) NULL,
	[Unique MD5] [varchar](32) NULL,
	[Urbanization] [varchar](255) NULL,
	[Village] [varchar](255) NULL,
	[ZIP] [varchar](255) NULL,
	[ZIP Addon] [varchar](255) NULL,
	[ZIP Plus 4] [varchar](255) NULL,
	[System Modstamp] [datetime] NULL,
 CONSTRAINT [PK_DimBiosAddress] PRIMARY KEY NONCLUSTERED 
(
	[BiosAddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [INDEXES]

GO
