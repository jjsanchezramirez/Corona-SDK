----------------------------------------------------------------------------------------------------
---- New Calendar View for Corona SDK (Original author: Juan Jose Sanchez Ramirez)
---- http://www.ApolloMobileApps.com
---- Copyright 2016 Apollo Mobile Apps
---- The MIT License (MIT) (see LICENSE.txt for details)
----------------------------------------------------------------------------------------------------
--
-- Date: January 6, 2015
--
-- Version: 1.0
--
-- File name: config.lua
--
---- App configuration settings are defined here using Lua syntax. It should be placed in the
---- project's base directory.
--
----------------------------------------------------------------------------------------------------

-- Calculate the aspect ratio
local aspectRatio = display.pixelHeight / display.pixelWidth

application = {

   content = {
   
      width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
      height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
      scale = 'letterBox',
      fps = 60,

      imageSuffix = {
         ['@2x'] = 1.5,
         ['@4x'] = 3.0,
      },
   },
}
