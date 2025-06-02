import json

def translate_text(text, source_lang, target_lang):
    response = translate.translate_text(
        Text=text,
        SourceLanguageCode=source_lang,
        TargetLanguageCode=target_lang
    )
    return response['TranslatedText']

def detect_and_translate(text, target_lang):
    # First detect the language
    comprehend = boto3.client('comprehend')
    lang_response = comprehend.detect_dominant_language(Text=text)
    source_lang = lang_response['Languages'][0]['LanguageCode']
    
    # Then translate
    return translate_text(text, source_lang, target_lang)

def start_batch_translation(input_s3_uri, output_s3_uri, source_lang, target_lang):
    response = translate.start_text_translation_job(
        InputDataConfig={
            'S3Uri': input_s3_uri,
            'ContentType': 'text/plain'
        },
        OutputDataConfig={
            'S3Uri': output_s3_uri
        },
        DataAccessRoleArn='arn:aws:iam::123456789012:role/TranslateBatchRole',
        SourceLanguageCode=source_lang,
        TargetLanguageCodes=[target_lang]
    )
    return response['JobId']

def translate_s3():
     s3 = boto3.client('s3')
    translate = boto3.client('translate')
    
    # Get the uploaded file
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # Download the file content
    response = s3.get_object(Bucket=bucket, Key=key)
    content = response['Body'].read().decode('utf-8')
    
    # Translate the content
    translated = translate.translate_text(
        Text=content,
        SourceLanguageCode='en',
        TargetLanguageCode='es'
    )['TranslatedText']
    
    # Save the translation
    new_key = f"translated/{key}"
    s3.put_object(
        Bucket=bucket,
        Key=new_key,
        Body=translated.encode('utf-8')
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Translation completed!')
    }

def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
