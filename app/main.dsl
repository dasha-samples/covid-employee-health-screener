import "commonReactions/all.dsl";

context 
{
    input phone: string;
}

/**
* Script.
*/

start node root 
{
    do 
    {
        #connectSafe($phone);
        #waitForSpeech(1000);
        #sayText("Hi, this is Dasha calling to complete your daily health checkup. Is it a good time to talk?");
        wait *;
    }    
    transitions 
    {
        will_call_back: goto will_call_back on #messageHasIntent("no");
        symptoms: goto symptoms on #messageHasIntent("yes");
    }
}

node will_call_back
{
    do
    {
        #sayText("No worries. Please make sure to call back before your shift. Looking forward to speaking to you soon! Bye!");
        #disconnect();
        exit;
    }
}

node symptoms
{
    do
    {
        #sayText("Perfect. Now, do you have any covid-like symptoms such as fever, sore throat, loss of smell or taste, et cetera?");
        wait *;
    }
    transitions
    {
        stay_home: goto stay_home on #messageHasIntent("yes") or #messageHasData("symptoms");
        vaccinated: goto vaccinated on #messageHasIntent("no");
    }
}

node stay_home
{
    do
    {
        #sayText("The corporate policy states that employees who present any symptoms should stay home, so I suggest you do just that. I'll call you tomorrow to check how you feel. Do you have any questions?");
        wait *;
    }
    transitions
    {``
        stay_home_policy: goto stay_home_policy on #messageHasIntent("yes") or #messageHasIntent("stay_home_policy");
        paid: goto paid on #messageHasIntent("payment");
        bye: goto bye on #messageHasIntent("no");
    }
}

node vaccinated
{
    do 
    {
        #sayText("That's good news! Did you get your vaccine?");
        wait *;
    }
    transitions 
    {
       yes_vac: goto yes_vac on #messageHasData("yes_vac") or #messageHasIntent("yes") or #messageHasIntent("vac_one");
       yes_two_vac: goto yes_two_vac on #messageHasIntent("yes_two_vac");
       no_vac: goto no_vac on #messageHasIntent("no_vac") or #messageHasIntent("no");
    }
}

node yes_vac
{
    do
    {
        #sayText("Got that. Have you received both doses of the vaccine?");
        wait *;
    }
    transitions
    {
        yes_two_vac: goto yes_two_vac on #messageHasIntent("yes") or #messageHasIntent("yes_two_vac");
        vac_one: goto vac_one on #messageHasIntent("no") or #messageHasIntent("vac_one");
    }
}

node vac_one
{
    do
    {
        #sayText("Uh-huh, got that. Have you possibly been in contact with someone who experiences any covid symptoms in the past 2 weeks?");
        wait *;
    }
    transitions
    {
        yes_two_vac: goto yes_two_vac on #messageHasIntent("no");
        watch_for_symptoms: goto watch_for_symptoms on #messageHasIntent("maybe") or #messageHasIntent("yes");
    }
}

node watch_for_symptoms
{
    do
    {
        #sayText("At this point you should look out for any symptoms that might appear. In case you notice any, please stay at home. Do you have any questions?");
        wait *;
    }
    transitions
    {
        paid: goto paid on #messageHasIntent("yes") or #messageHasIntent("payment");
        stay_home_policy: goto stay_home_policy on #messageHasIntent("stay_home_policy");
        bye: goto bye on #messageHasIntent("no");
    }
}

node yes_two_vac
{
    do
    {
        #sayText("Awesome! We're looking forward to seeing you at work in a bit. Talk to you tomorrow! Bye!");
        #disconnect();
        exit;
    }
}

node no_vac
{
    do
    {
        #sayText("Mhm, got that. Are you planning on getting vaccinated?");
        wait *;
    }
    transitions
    {
        will_vaccinate: goto will_vaccinate on #messageHasIntent("yes") or #messageHasIntent("will_vaccinate");
        wont_vaccinate: goto wont_vaccinate on #messageHasIntent("wont_vaccinate");
        bye: goto bye on #messageHasIntent("no");
    }
}

node will_vaccinate
{
    do
    {
        #sayText("Perfect, I'm glad to hear that! Please make sure to let the HR know once you get vaccinated. Thank you for taking time to reply to the questions, we'll see you at work in a bit. Bye!");
        exit;
    }
}

node wont_vaccinate
{
    do
    {
        #sayText("It's recommended you get vaccinated if you don't have any medical limitations. In the meantime, please exercise social distancing and wear your PPE.");
    }
transitions
    {
        bye: goto bye;
    }
}

digression stay_home_policy
{
    conditions {on #messageHasIntent("stay_home_policy");}
    do 
    {
        #sayText("Great question! Employees who have any covid-like symptoms should stay at home for 24 hours after the symptoms go away completely.");
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node
        return; 
    }
}

node stay_home_policy
{
    do 
    {
        #sayText("Employees who have any covid-like symptoms should stay at home for 24 hours after the symptoms go away completely. May I help with anything else?");
        wait *;
    }
    transitions 
    {
       paid: goto paid on #messageHasIntent("payment");
       bye: goto bye on #messageHasIntent("no");  
    }
}

node paid
{
    do 
    {
        #sayText("Yes, absolutely. Your leave will be paid for. Do you have any other questions?");
        wait *;
    }
    transitions 
    {
       question: goto question on #messageHasIntent("yes") or #messageHasIntent("question");
       bye: goto bye on #messageHasIntent("no");    
    }
}

node question
{
    do 
    {
        #sayText("I'm sorry but I'm not quite sure I can answer that. I suggest you contact HR about that. Is that okay?");
        wait *;
    }
    transitions 
    {
       bye: goto bye on #messageHasIntent("yes");
       can_help_then_: goto bye on #messageHasIntent("no");    
    }
}

digression paid
{
    conditions {on #messageHasIntent("payment");}
    do 
    {
        #sayText("Yes, absolutely. Your leave will be paid for.");
        #repeat(); // let the app know to repeat the phrase in the node from which the digression was called, when go back to the node
        return; // go back to the node from which we got distracted into the digression
    }
}

node bye
{
    do
    {
        #sayText("Great! Thank you for taking time to reply to the questions, we're looking forward to seeing you at work in a bit. Talk to you tomorrow! Bye!");
        #disconnect();
        exit;
    }
}


node can_help_then 
{
    do
    {
        #sayText("How can I help you then?");
        wait *;
    }
    transitions 
    {
       question: goto question on #messageHasIntent("yes") or #messageHasIntent("question");
    }
}

digression bye 
{
    conditions { on #messageHasIntent("bye"); }
    do 
    {
        #sayText("Thanks for your time. Have a great day. Bye!");
        #disconnect();
        exit;
    }
}