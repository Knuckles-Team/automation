from PIL import Image
import os
import datetime


#class PhotoManager():
def get_date_taken(file_path):
    # Open the image file
    with Image.open(file_path) as img:
        try:
            # Get the timestamp from the image (if available)
            exif_data = img._getexif()
            if 36867 in exif_data:
                timestamp = exif_data[36867]
                # Convert the timestamp to a datetime object
                date_taken = datetime.datetime.strptime(timestamp, "%Y:%m:%d %H:%M:%S")
                return date_taken
        except (AttributeError, KeyError, TypeError):
            print(f"EXIF DATA: {exif_data}")
            file_name, file_extension = os.path.splitext(os.path.basename(file_path))
            try:
                date_taken = datetime.datetime.strptime(file_name, "%Y%m%d_%H%M%S")
            except (AttributeError, KeyError, TypeError):
                return None
            return date_taken


    #def create_directory():


# Replace 'path_to_your_png_file.png' with the actual path to your PNG file
image_file_path = 'C:/Users/knuck/Downloads/20230901_162342.jpg'

if (os.path.isfile(image_file_path)
        and (image_file_path.lower().endswith('.png')
             or image_file_path.lower().endswith('.jpg')
             or image_file_path.lower().endswith('.jpeg'))):
    date_taken = get_date_taken(image_file_path)
    if date_taken:
        print(f"{image_file_path} Date Taken:", date_taken)
    else:
        print(f"{image_file_path} Date Taken information not found in the image's EXIF data.")
else:
    print("Invalid PNG file path.")