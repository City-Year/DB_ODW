USE [ODW]
GO
/****** Object:  Table [dbo].[zContacts]    Script Date: 12/1/2016 9:20:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zContacts](
	[Account ID] [varchar](18) NULL,
	[First Name] [varchar](40) NULL,
	[Last Name] [varchar](80) NULL,
	[Full Name] [varchar](121) NULL,
	[Email] [varchar](80) NULL,
	[Mailing Street] [varchar](255) NULL,
	[Mailing City] [varchar](40) NULL,
	[Mailing Zip/Postal Code] [varchar](20) NULL,
	[Mailing Country] [varchar](80) NULL,
	[Gender] [varchar](255) NULL,
	[Title] [varchar](128) NULL,
	[Preferred Contact?] [int] NULL
) ON [PRIMARY]

GO
