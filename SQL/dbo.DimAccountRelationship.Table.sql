USE [ODW]
GO
/****** Object:  Table [dbo].[DimAccountRelationship]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAccountRelationship](
	[AccountRelationshipID] [int] IDENTITY(1,1) NOT NULL,
	[Received Connection ID] [varchar](18) NULL,
	[Sent Connection ID] [varchar](18) NULL,
	[Created By ID] [varchar](18) NULL,
	[Created Date] [datetime] NULL,
	[Record ID] [varchar](18) NULL,
	[Deleted] [int] NULL,
	[Last Activity Date] [datetime] NULL,
	[Last Modified By ID] [varchar](18) NULL,
	[Last Modified Date] [datetime] NULL,
	[Reference #] [varchar](80) NULL,
	[Owner ID] [varchar](18) NULL,
	[Account From] [varchar](18) NULL,
	[Account To] [varchar](18) NULL,
	[Active?] [int] NULL,
	[Archive?] [int] NULL,
	[Category] [varchar](255) NULL,
	[Comments] [varchar](255) NULL,
	[Comments?] [int] NULL,
	[Contact From] [varchar](18) NULL,
	[Contact To] [varchar](18) NULL,
	[Degree] [varchar](255) NULL,
	[Department] [varchar](255) NULL,
	[Graduation Year] [decimal](4, 0) NULL,
	[Job Title] [varchar](255) NULL,
	[Major] [varchar](255) NULL,
	[Opportunity] [varchar](18) NULL,
	[Position] [varchar](255) NULL,
	[Primary?] [int] NULL,
	[Role @Deprecated(Version=2.0)] [varchar](255) NULL,
	[Role 1] [varchar](255) NULL,
	[Role 2] [varchar](255) NULL,
	[Starting Day] [varchar](255) NULL,
	[Starting Month] [varchar](255) NULL,
	[Starting Year] [varchar](255) NULL,
	[Stopping Day] [varchar](255) NULL,
	[Stopping Month] [varchar](255) NULL,
	[Stopping Year] [varchar](255) NULL,
	[Record Type ID] [varchar](18) NULL,
	[System Modstamp] [datetime] NULL,
	[Account Name no Household From] [varchar](255) NULL,
	[Account Name no Household To] [varchar](255) NULL,
	[Full Name From] [varchar](250) NULL,
	[Full Name To] [varchar](250) NULL,
 CONSTRAINT [PK_DimAccountRelationship] PRIMARY KEY CLUSTERED 
(
	[AccountRelationshipID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
