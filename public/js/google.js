function logout()
    {
        gapi.auth.signOut();
        location.reload();
    }
    function login() 
    {
      var myParams = {
        'clientid' : '109237702906-qla8he89gumqah6npjq36e7a90ubghm9.apps.googleusercontent.com',
        'cookiepolicy' : 'single_host_origin',
        'callback' : 'loginCallback',
        'approvalprompt':'force',
        'scope' : 'https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/plus.profile.emails.read'
      };
      gapi.auth.signIn(myParams);
    }

    function loginCallback(result)
    {
        if(result['status']['signed_in'])
        {
            var request = gapi.client.plus.people.get(
            {
                'userId': 'me'
            });
            
            request.execute(function (resp)
            {
                var email = '';
                if(resp['emails'])
                {
                    for(i = 0; i < resp['emails'].length; i++)
                    {
                        if(resp['emails'][i]['type'] == 'account')
                        {
                            email = resp['emails'][i]['value'];
                            
                        }
                    }
                }

                var str = "Name:" + resp['displayName'] + "<br>";
                // str += "Image:" + resp['image']['url'] + "<br>";
                // str += "<img src='" + resp['image']['url'] + "' /><br>";

                str += "URL:" + resp['url'] + "<br>";
                str += "Email:" + email + "<br>";


                var name = resp['displayName'];
                var email = resp['emails'][0]['value'];
                // console.log(resp);
                // console.log('name' + name);
                // console.log('email' + email);
                $('input[name="gname"]').attr("value", name);
                $('input[name="gemail"]').attr("value", email);   
                $("#google_login").submit(); 
            }); 
        }
    }
    
    function onLoadCallback()
    {
        gapi.client.setApiKey('AIzaSyBzSbwwlHLUGEws0R9Coa9MXz6vcdAtf6k');
        gapi.client.load('plus', 'v1',function(){});
    }




  (function() {
   var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
   po.src = 'https://apis.google.com/js/client.js?onload=onLoadCallback';
   var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
 })();