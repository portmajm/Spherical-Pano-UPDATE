
# The purpose of this script is to provide an easily sourceable function to batch process spherical panoramas into upward looking hemispherical images oriented northward to the top of the image.


# Install/load necessary packages

auto_install_package <- function(package_names_list){
  for(package_name in package_names_list){
    if(!(package_name %in% rownames(installed.packages()))){
      install.packages(package_name, dependencies = TRUE)
    }
    library(package_name, character.only = TRUE)
  }
}

auto_install_package(c("magick", "dplyr", "exifr"))

# Get hemispherical image mask file
download.file(url = "https://raw.githubusercontent.com/andisa01/Spherical-Pano-UPDATE/main/HemiPhotoMask.svg",
              destfile = "./TEMPmask.svg",
              mode = "wb")

# The only argument for this function , "focal_path" is the path to the raw equirectangular panos. Place all of your panos in this subdirectory within your working directory

convert_spheres_to_hemis <- 
  function(focal_path){
    
    list_of_panos <- list.files(focal_path) # Get the list of all panos.
    output <- c() # Instantiate an empty object to receive the results.
    
    for(i in 1:length(list_of_panos)){
      
      print(paste0("Processing ", i, " of ", length(list_of_panos), " spherical panos."))
      
      if(i == 1){
        T0 <- Sys.time() # Used for estimating remaining time
      }
      T1 <- Sys.time() # Used for timecheck
      
      focal_image_path <- paste0(focal_path, list_of_panos[i])
      focal_image_name <- sub("\\.[^.]+$", "", basename(focal_image_path))
      
      # You can choose which variables you'd like to retain
      xmp_data <- 
        read_exif(focal_image_path) %>%
        select(
          SourceFile,
          Make,
          Model,
          FullPanoWidthPixels,
          FullPanoHeightPixels,
          SourcePhotosCount,
          Megapixels,
          LastPhotoDate,
          GPSLatitude,
          GPSLongitude,
          GPSAltitude,
          PoseHeadingDegrees
        ) %>%
        mutate(HemiImageFile = paste0(focal_image_name, "hemi_masked.jpg"))
      
      output <-
        bind_rows(output,
                  xmp_data)
      
      write.csv(output, "./canopy_output.csv", row.names = FALSE)
      
      # The first step in the process is to convert the equirectangular image from our phone into a hemispherical image.
      
      ### Convert the equirectangular image to hemisphere
      
      pano <- image_read(focal_image_path)
      
      # Store the pano width to use in scaling and cropping the image
      pano_width <- image_info(pano)$width
      
      # Store the pano heading in order to rotate the hermispherical image to standardize true north as the top of the image. This only matters for analyses like global site factor or through-canopy radiation that require plotting a sunpath over the hemisphere.
      image_heading <- read_exif(focal_image_path)$PoseHeadingDegrees
      
      # To process the image, we need to scale it, reproject it into polar coordinates, reorient it, and rotate it to true north.
      pano_hemisphere <- pano %>%
        # Crop to retain the upper hemisphere
        image_crop(geometry_size_percent(100, 50)) %>%
        # Rescale into a square to keep correct scale when projecting in to polar coordinate space
        image_resize(geometry_size_percent(100, 400)) %>%
        # Remap the pixels into polar projection
        image_distort("Polar",
                      c(0),
                      bestfit = TRUE) %>%
        image_flip() %>%
        # Rotate the image to orient true north to the top of the image
        image_rotate(image_heading) %>%
        # Rotating expands the canvas, so we crop back to the dimensions of the hemisphere's diameter
        image_crop(paste0(pano_width, "x", pano_width, "-", pano_width/2, "-", pano_width/2))
      
      ### Create black mask for the image (this isn't really neccessary, but makes the images look nicer)
      # Get the image mask vector file
      image_mask <- image_read("./HemiPhotoMask.svg") %>%
        image_transparent("white") %>%
        image_resize(geometry_size_pixels(width = pano_width, height = pano_width)) %>%
        image_convert("png")
      
      masked_hemisphere <- image_mosaic(c(pano_hemisphere, image_mask))
      
      # We'll store the masked hemispheres in their own subdirectory.
      if(dir.exists("./masked_hemispheres/") == FALSE){
        dir.create("./masked_hemispheres/")
      } # If the subdirectory doesn't exist, we create it.
      
      masked_hemisphere_path <- paste0("./masked_hemispheres/", focal_image_name, "hemi_masked.jpg") # Set the filepath for the new image
      
      image_write(masked_hemisphere, masked_hemisphere_path) # Save the masked hemispherical image
      
      T2 <- Sys.time()
      T_instance <- difftime(T2, T1, units = "secs")
      T_total <- difftime(T2, T0, units = "secs")
      T_average <- T_total/i
      
      print(paste0("Completed ", i, " of ", length(list_of_panos), " images in ", round(T_instance, 0), " seconds."))
      print(paste0("Estimated ", round(((length(list_of_panos) - i) * T_average)/60, 1), " minutes remaining."))
    }
    
    write.csv(output, "./canopy_output.csv", row.names = FALSE)
    
  }
