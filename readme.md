Databases:

1. Production database currently in use "lockerroom"
2. Development database used for testing and adding new features "devlocker"


To add new campaigns:

STEP 1: can use future dates

a) Add to campaigns table: campaign_name, start_date, end_date, contact_name, contact_email
b) Add 200x200px logo in img/campaigns/<campaign name>/logo.jpg (remove any spaces and hyphens from the file name). If you don't have logo yet then copy the default one in the campaign folder.

STEP 2: Before the start date

a) add to campaign_items table: campaign_name, item (these are t-shirts, sweatpants, etc)
b) add 400x400px images to img/campaigns/<campaign name>/ folder. Call the images the same as the item names (without spaces and hyphens)

STEP 3: To enable ordering. nb this part still requires refactoring prior to next campaign

a) add to products table: campaign_name, item, item_description, size, price, personalize_name, personalize_number 