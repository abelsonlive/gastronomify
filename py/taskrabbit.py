from selenium import webdriver
from datetime import datetime
import os, time

# TASK OBJECT

def taskrabbit(task):
  """
  taskrabbit works by taking in a task dictionary with the following key value pairs:

  summary : a summary of the task
  address : where the result should be delivered
  price : the price you'll pay for the task
  category : What category you want to file the task under, gastronomification is probably "Other"
  finish_date : When the task needs to be finished by (%Y-%m-%d format)
  finish_time : The time by which the task needs to be finished (6am - 11pm)
  description : A detailed description of the task - should include nice text formatting

  You should have TASKRABBIT_EMAIL and TASKRABBIT_PASSWORD set as Global Variables

  You should also have your Credit Card Info stored on your taskrabbit.com profile

  When it's done you should get an email notification of your new task!
  """
  # transform dates
  date_object = datetime.strptime(task['finish_date'], "%Y-%m-%d")
  month_year = date_object.strftime("%B %Y")
  day = date_object.day

  # taskrabbit info
  TASKRABBIT_URL = "http://www.taskrabbit.com/"
  TASKRABBIT_EMAIL = os.getenv("TASKRABBIT_EMAIL")
  TASKRABBIT_PASSWORD = os.getenv("TASKRABBIT_PASSWORD")

  # setup browser
  browser = webdriver.Chrome()

  # open taskrabbit and login
  browser.get(TASKRABBIT_URL)
  browser.find_element_by_id('login').click()
  browser.find_element_by_id('user_session_email').send_keys(TASKRABBIT_EMAIL)
  browser.find_element_by_id('user_session_password').send_keys(TASKRABBIT_PASSWORD)
  browser.find_element_by_id('user_session_submit').click()
  time.sleep(2)

  # login to the task view
  browser.find_element_by_xpath('//*[@id="header-actions"]/a[1]').click()
  time.sleep(2)

  # input fields
  browser.find_element_by_id('task_name').send_keys(task['summary'])
  browser.find_element_by_id('task_description').send_keys(task['description'])
  browser.find_element_by_id('s2id_task_category_id').click()
  browser.find_element_by_id('task_locations_attributes_0_freeform_address').send_keys(task['address'])

  #submit the price, clear the field first so we don't pay a ton!!!
  browser.find_element_by_id('task_named_price').clear()
  browser.find_element_by_id('task_named_price').send_keys(str(task['price']))

  # tell the browser we're using "Finish By"
  browser.find_element_by_id('s2id_task_start_end').click()
  browser.find_element_by_id('s2id_task_start_end').click()

  # Open the datepicker
  browser.find_element_by_class_name('datepicker').click()

  # determine the active month, if it doesn't match that of our selected date, click through to other months until it does
  active_month = browser.find_element_by_class_name('switch').text
  while active_month != month_year:
    browser.find_element_by_class_name('icon-arrow-right').click()
    time.sleep(0.5)
    active_month = browser.find_element_by_class_name('switch').text

  # click on our desired day
  browser.find_element_by_xpath("//td[contains(text(), '%s')]" % day).click()


  #TODO TIME RANGE AND CATEGORY, FOR SOME REASON THESE ITEMS AREN'T VISIBLE IN THE DOM
  # set attribute script:
  def make_visible(element_id):
    return "document.getElementById('%s').setAttribute('style', 'display: block;')" % element_id

  # tell the browser that the dropdown options are now visible
  browser.execute_script(make_visible('task_time'))
  browser.execute_script(make_visible('task_category_id'))

  # select task time
  times = browser.find_element_by_id("task_time").find_elements_by_tag_name("option")
  for t in times:
    if t.text==task['finish_time']:
      t.click()

  # select category
  categories = browser.find_element_by_id('task_category_id').find_elements_by_tag_name("option")
  for c in categories:
    if c.text==task['category']:
      c.click()

  # submit the task!!!
  browser.find_element_by_xpath('//*[@id="new_task"]/fieldset/input').click()
  time.sleep(5)

  return "Check %s for notification that your task went through!" % TASKRABBIT_EMAIL

if __name__ == '__main__':
  task = {
    "summary": "Make Data-Driven Fruit Salad for the MIT Media Lab",
    "address": "MIT Media Lab | Building E14 | 77 Massachusetts Avenue | Cambridge, MA 02139",
    "price": 100,
    "category": "Other", #
    "finish_date": "2013-06-23",
    "finish_time": "7pm", #6am - 11pm
    "description": "There are 4 fruit salad recipes below. They are named\n*  Diet 1 \n*  Diet 2 \n*  Diet 3 \n*  Diet 4 \n\nPlease make each recipe in a separate bowl.\nLabel each bowl according to its recipe,\nand deliver the food to the specified place and time.\nThe recipes follow.\n\n               Diet 1\napples      3.0622331\nbananas     0.6741632\ncherries    7.4511099\ngrapes      9.3600661\nkiwis       1.3602364\nlemons      0.3123323\nmangos      0.9009303\nnectarines  1.1383358\noranges     1.1554227\npineapples  0.4297087\nraspberries 6.0614287\nwatermelons 0.1745475\n\n\n                Diet 2\napples       2.9597315\nbananas      0.9520856\ncherries    11.5328243\ngrapes      12.8646019\nkiwis        1.8260780\nlemons       0.4593157\nmangos       0.9874277\nnectarines   1.7863692\noranges      1.8113601\npineapples   0.4844688\nraspberries  7.8742339\nwatermelons  0.2385661\n\n\n                Diet 3\napples       2.9743746\nbananas      1.1068131\ncherries    13.8807299\ngrapes      17.1432489\nkiwis        2.5857183\nlemons       0.6913506\nmangos       1.0276590\nnectarines   2.7679522\noranges      2.7983727\npineapples   0.5239792\nraspberries  8.4005679\nwatermelons  0.2742629\n\n\n                Diet 4\napples       3.0036608\nbananas      1.2669381\ncherries    15.1353359\ngrapes      16.6320831\nkiwis        2.2279672\nlemons       0.5370014\nmangos       1.0839829\nnectarines   2.3073428\noranges      2.2348445\npineapples   0.5618434\nraspberries  9.6637695\nwatermelons  0.3126236\n"
  }
  print taskrabbit(task)
