#set working directory
setwd("D:/Kanwil Riau/Updating NPGT Perkebunan/OLAH TIM/RIAU")

#load library
library(raster)

#set environment
rasterOptions(progress = "Text", tmpdir = paste0(getwd(), "/tmp"))

#set path for output (sesuaikan dengan folder anda)
path.image <- "D:/Kanwil Riau/Updating NPGT Perkebunan/OLAH TIM/RIAU/Run/Image"
path.mask <- "D:/Kanwil Riau/Updating NPGT Perkebunan/OLAH TIM/RIAU/Run/Mask"
path.image.val <- "D:/Kanwil Riau/Updating NPGT Perkebunan/OLAH TIM/RIAU/Run/Predict"

#load data raster
image <- raster("RIAU.tif")
mask <- raster("MASK_RIAU.tif")
validation <- raster("VALID_RIAU.tif")

plot(mask)
plot(image)
plot(validation)

#lakukan data fisnet
fishnet.training <- shapefile("Fn_Training_Riau.shp")
fishnet.validation <- shapefile("Fn_Validation_Riau.shp")

for(i in 1:length(fishnet.training)) {
  sub <- fishnet.training[i,]
  val <- sub$Class
  
  # Membuat raster mask dan mengambil extent-nya
  mask2 <- raster(sub)
  ext <- extent(mask2)
  
  # Memotong image dan mask menggunakan extent dari mask
  split.image <- crop(image, ext)
  split.mask <- crop(mask, ext)
  
  # Memeriksa ukuran dari citra yang dipotong
  print(paste0(ncol(split.image), " x ", nrow(split.image)))
  
  # Mengecek apakah ada nilai NA pada split.image
  val <- values(split.image)
  if (isTRUE(any(is.na(val)))) {
    print(paste0("skip ", i, " no data"))
  } else {
    print(paste0("store data ", i))
    
    # Menampilkan mask
    plot(split.mask)
    
    # Menulis citra dengan banyak band
    # Jika 'split.image' memiliki lebih dari satu band, gunakan 'writeRaster' dengan opsi `bylayer=FALSE` untuk menyimpan semua band dalam satu file
    writeRaster(split.image, paste0(path.image, "/", "data_image_", i, "_sel_1024.tif"), 
                format = "GTiff", datatype = "INT2S", overwrite = TRUE, options = c("INTERLEAVE=BAND"))
    
    # Menulis mask (jika ini single-band raster, tidak perlu opsi khusus)
    writeRaster(split.mask, paste0(path.mask, "/", "mask_image_", i, "_sel_1024.tif"), 
                format = "GTiff", datatype = "INT2S", overwrite = TRUE)
  }
}


#lakukan proses tiling data validasi
for(i in 1:length(fishnet.validation)){
  sub <- fishnet.validation[i,]
  mask2 <- raster(sub)
  ext <- extent(mask2)
  split.image <- crop(validation, ext)
  plot(split.image)
  print(paste0(ncol(split.image), " x ", nrow(split.image)))
  print(paste0("store data ", i))
  writeRaster(split.image, paste0(path.image.val, "/", "validation_image_", i, "_sel_1024.tif"), format = "GTiff", datatype =
                "INT2S", overwrite = T)
}
