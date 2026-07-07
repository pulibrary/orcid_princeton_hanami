# CheckMK is utilized to monitor the service
## Uptime checks
 [staging Status check for the Web Service](https://pulmonitor.princeton.edu/staging/check_mk/index.py?start_url=%2Fstaging%2Fcheck_mk%2Fview.py%3Fhost%3Dorcid-staging.princeton.edu%26site%3Dstaging%26view_name%3Dhost)
 
 [production status checks for the web service](https://pulmonitor.princeton.edu/production/check_mk/index.py?start_url=%2Fproduction%2Fcheck_mk%2Fview.py%3Fhost%3Dorcid.princeton.edu%26site%3Dproduction%26view_name%3Dhost)
### The uptime check configuration
  The uptime check is configured in the notifications.  
  
  The "Sending Conditions" determine how often and how soon you will see an alert. The period of frequency set at the system level should be 1 minute.
  If you want to see the first alert at 5 minutes out you need to set the "Limit notifications by count to" 6 through 99999. The first occurs immediately when the system goes down.
  If you want to see that the system is still down after an hour you need to set the "Throttling of 'Periodic notifications'" to 6 and send every 60
  
  [staging uptime check configuration](https://pulmonitor.princeton.edu/staging/check_mk/index.py?start_url=%2Fstaging%2Fcheck_mk%2Fwato.py%3Fback_mode%3Dtest_notifications%26edit%3D9%26folder%3D%26mode%3Dnotification_rule_quick_setup%26user%3D)
    
  [production uptime check configuration](https://pulmonitor.princeton.edu/production/check_mk/index.py?start_url=%2Fproduction%2Fcheck_mk%2Fwato.py%3Fback_mode%3Dtest_notifications%26edit%3D4%26folder%3D%26mode%3Dnotification_rule_quick_setup%26user%3D)
    
