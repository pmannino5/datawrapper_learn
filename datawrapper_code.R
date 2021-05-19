# This short script begins using the Datawrapper API
# Fortunately, there is a nice package called DatawRappr that makes using the API very easy.
# https://munichrocker.github.io/DatawRappr/index.html
# For this learning script, I'm going to use the exoneration data I downloaded a couple years ago
# and make a line graph of exonerations per year
# I'll work on additional charts and tables in the future

library(DatawRappr)
library(dplyr)

# set working directory
setwd('/Users/petermannino/Documents/Exoneration')

# import the exoneration dataset
exon_dat<-readxl::read_excel('publicspreadsheet.xlsx')

# set up connection with datawrapper api 
datawrapper_auth(api_key="your api key")
dw_test_key() # test connection

# summarize total exonerations per year
dw_data<-exon_dat %>%
  mutate(year = lubridate::year(`Posting Date`)) %>%
  group_by(year) %>%
  summarise(Total_Exonerations=n())

# Create an empty chart in datawrapper
dw_chart<-dw_create_chart()

# Add data to the chart
dw_data_to_chart(x=dw_data, chart_id=dw_chart)

# Set chart type
dw_edit_chart(chart_id = dw_chart, type = "d3-lines")

# Edit other attributes of the chart
dw_edit_chart(chart_id=dw_chart,
              title="Exonerations Per Year", # Title
              annotate = "Data Downloaded in 2019", # Note at the bottom of chart
              source_name = "National Registry of Exonerations at the University of Michigan", # Source name at bottom
              visualize = list("y-grid-labels" = "inside", # Put the Y-labels within the chart
                               "base-color" = 3, # change the color of the line
                               "line-dashes" = list(Total_Exonerations=2))) # Make the line dashed

# Export the chart
export_chart<-dw_export_chart(chart_id = dw_chart, 
                              type=c("png"), 
                              plain =FALSE) # This ensures the title, annotations, and everything is included

export_chart # look at the chart

# The exported chart is a magick class object, so use image_write from that package to save
magick::image_write(export_chart,"dw_png.png")

# Publish the chart online
dw_publish_chart(chart_id = dw_chart)

# Delete it
dw_delete_chart(dw_chart)






