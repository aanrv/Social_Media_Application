//
//  PostStoryViewController.swift
//  yMe
//
//  Created by Qi Feng Huang on 10/16/15.
//  Copyright © 2015 hackathon. All rights reserved.
//

import UIKit
import QuartzCore

class PostStoryViewController: UIViewController, UITextViewDelegate {
    
    let inputWindowWidth:CGFloat = 300
    let inputWindowHeight:CGFloat = 30
    let inputTextWindowHeight:CGFloat = 200
    let PLACEHOLDER_TEXT = "Write your post"
    var postCategory:Int?
    
    let numPosts: Int
    let textInput: UITextView
    let nameInput: UITextField
    let titleInput: UITextField
    let catButton:UISegmentedControl
    
    init(numPosts : Int) {
        
        let screenSize = CGSize(width: 375, height: 667)
        let startX:CGFloat = (screenSize.width) * 0.1
        let startY:CGFloat = (screenSize.height) * 0.1
        
        self.textInput = UITextView(frame: CGRect(x: startX, y: startY + 180, width: inputWindowWidth, height: inputTextWindowHeight))
        self.textInput.layer.cornerRadius = 5
        self.textInput.font = UIFont(name: "GillSans", size: 14)
        self.nameInput = UITextField(frame: CGRect(x: startX, y: startY + 60, width: inputWindowWidth, height: inputWindowHeight))
        self.titleInput = UITextField(frame: CGRect(x: startX, y: startY, width: inputWindowWidth, height: inputWindowHeight))
        
        self.numPosts = numPosts
        
        self.catButton = UISegmentedControl(frame: CGRect(x: startX, y: startY + 120, width: inputWindowWidth, height: inputWindowHeight))
        
        
        super.init(nibName: nil, bundle: nil)
        
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenSize = self.view.window?.frame.size
        
        if screenSize == nil{
            screenSize = CGSize(width: 375, height: 667)
        }
        
        let sendButton = UIButton(frame: CGRect(x: self.view.frame.size.width * 0.6, y: self.view.frame.size.height*0.85, width: 60, height: 60))
        sendButton.layer.zPosition = 200
        sendButton.setTitle("Done", forState: UIControlState.Normal)
        sendButton.addTarget(self, action: "postStory", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(sendButton)
        
        let cancelButton = UIButton(frame: CGRect(x: screenSize!.width * 0.25, y: screenSize!.height*0.85, width: 60, height: 60))
        cancelButton.addTarget(self, action: "cancelButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        self.view.addSubview(cancelButton)
        
        titleInput.placeholder = "Title of post"
        titleInput.borderStyle = UITextBorderStyle.RoundedRect
        titleInput.textAlignment = NSTextAlignment.Center
        titleInput.font = UIFont(name: "GillSans", size: 14)
        
        nameInput.placeholder = "Username"
        nameInput.borderStyle = UITextBorderStyle.RoundedRect
        nameInput.textAlignment = NSTextAlignment.Center
        nameInput.font = UIFont(name: "GillSans", size: 14)
        
        catButton.insertSegmentWithTitle("Abuse", atIndex: 0, animated: true)
        catButton.insertSegmentWithTitle("Depression", atIndex: 1, animated: true)
        catButton.insertSegmentWithTitle("Discrimination", atIndex: 2, animated: true)
        catButton.insertSegmentWithTitle("Exclusion", atIndex: 3, animated: true)
        catButton.insertSegmentWithTitle("Oppression", atIndex: 4, animated: true)
        catButton.insertSegmentWithTitle("Misc", atIndex: 5, animated: true)
        catButton.addTarget(self, action: "catButtonSwitched:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.addSubview(titleInput)
        self.view.addSubview(catButton)
        self.view.addSubview(nameInput)
        self.view.addSubview(textInput)
        
        textInput.delegate = self
        applyPlaceholderStyle(textInput, placeholderText: PLACEHOLDER_TEXT)
        
    }
    
    func cancelButtonAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGrayColor()
        aTextview.text = placeholderText
    }
    
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkTextColor()
        aTextview.alpha = 1.0
    }
    
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
        if aTextView == textInput && aTextView.text == PLACEHOLDER_TEXT
        {
            // move cursor to start
            moveCursorToStart(aTextView)
        }
        return true
    }
    
    func moveCursorToStart(aTextView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == textInput && textView.text == PLACEHOLDER_TEXT
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: PLACEHOLDER_TEXT)
            moveCursorToStart(textView)
            return false
        }
    }

    func postStory() {
        //nothing
        //ADD CATEGORY
        if (!textInput.hasText() || !nameInput.hasText() || !titleInput.hasText() || self.postCategory == nil){
            return
        }
        
        print("Posting story")
        
        let newPost:PFObject = PFObject(className: "Post")
        
        
        
        newPost.setValue(postCategory, forKey: "category")
        newPost.setValue(String(self.numPosts + 1), forKey: "uid")
        newPost.setValue(textInput.text, forKey: "content")
        newPost.setValue(nameInput.text, forKey: "cc_by")
        newPost.setValue(titleInput.text, forKey: "title")
        newPost.setValue(0, forKey: "likes")
        newPost.setValue([], forKey: "comments")

        
        newPost.saveInBackground()
        
        self.cancelButtonAction()
    }
    
    
    func catButtonSwitched(sender : UISegmentedControl){
        self.postCategory = sender.selectedSegmentIndex as Int
    }
    
    

}
