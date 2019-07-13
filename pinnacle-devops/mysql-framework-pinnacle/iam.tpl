{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "NotAction": [
                 "organizations:*"
             ],
             "Resource": "*"
         },
         {
             "Effect": "Allow",
             "Action": [
                 "iam:*",
                 "organizations:DescribeOrganization"
             ],
             "Resource": "*"
         }
     ]
}