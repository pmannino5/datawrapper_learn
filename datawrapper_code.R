# This short script begins using the Datawrapper API
# Fortunately, there is a nice package called DatawRappr that makes using the API very easy.
# https://munichrocker.github.io/DatawRappr/index.html
# For this learning script, I'm going to use the exoneration data I downloaded a couple years ago
# and make a line graph of exonerations per year and table of exonerations by race
# I'll work on additional charts and tables in the future

library(DatawRappr)
library(dplyr)

# set working directory
setwd('/Users/petermannino/Documents/Exoneration')

# download the exoneration dataset
exon_dat<-readxl::read_excel('publicspreadsheet.xlsx')

# set up connection with datawrapper api 
datawrapper_auth(api_key="your api key")


dw_test_key() # test connection

##### Make a line graph in datawrapper #####

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

##### Make a table in datawrapper #####

# df of exonerations by race
dw_table_dat<-exon_dat %>%
  group_by(Race) %>%
  summarize(Total_Exonerations = n())

dw_table<-dw_create_chart(type='tables') # create empty table

dw_data_to_chart(chart_id = dw_table, x = dw_table_dat) # add data to table

# Add title, annotations, and source to table
dw_edit_chart(chart_id = dw_table,
              title = "Exonerations by Race",
              source_name = "National Exoneration Registry at the University of Michigan",
              annotate = "Data downloaded in 2019")

# Edit visuals
dw_edit_chart(chart_id = dw_table,
              visualize = list(header=list(style=list(bold=TRUE, # bold the header
                                                      background="#f0f0f0"), # make the background gray
                                           borderBottom="2px"), # make the line below the header thicker
                               striped=TRUE, # make the table stripped
                               sortTable=TRUE, # Sort the table
                               sortBy = "Total_Exonerations")) # by exonerations

# export table
table_export<-dw_export_chart(chart_id = dw_table, type=c("png"), plain = FALSE) 
table_export

# Save the table
magick::image_write(table_export, "table_export.png")

# publish table online
dw_publish_chart(dw_table)

# delete table
dw_delete_chart(chart_id = dw_table)
