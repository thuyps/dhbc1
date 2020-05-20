//
//  TextUtils.m
//  batchu
//
//  Created by Pham Quang Dung on 10/12/13.
//  Copyright (c) 2013 Weplay.vn. All rights reserved.
//

#import "TextUtils.h"
#import "ExtendNSString.h"

#define  VN_CHARACTERS_1 @"AEIOUY"
#define  VN_CHARACTERS_2 @"BCDGHKLMNPQRSTVX"
#define  NUMBERS = @"0123456789"

@implementation TextUtils

-(id)init
{
    self = [super init];
    
   // vietnameseindex = @"0123456789AÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬBCDĐEÈÉẺẼẸÊỀẾỂỄỆFGHIÌÍỈĨỊKLMNOÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢPQRS TUÙÚỦŨỤƯỪỨỬỮỰVXYỲÝỶỸỴZaàáảãạăằắẳẵặâầấẩẫậbcdđeèéẻẽẹêếềệểễfghiìíỉĩịklmnoòóỏõọôồốổỗộơờớởỡợpqrstuùúủũụưừứửữựvxyỳýỷỹỵz";
    
    codau = [NSArray arrayWithObjects:
              @"ÁÀẠẢÃÂẤẦẬẨẪĂẮẰẶẲẴ",
              @"ÉÈẸẺẼÊẾỀỆỂỄ",
              @"ÓÒỌỎÕÔỐỒỘỔỖƠỚỜỢỞỠ",
              @"ÚÙỤỦŨƯỨỪỰỬỮ",
              @"ÍÌỊỈĨ",
              @"Đ",
              @"ÝỲỴỶỸ",
              @"áàạảãâấầậẩẫăắằặẳẵ",
              @"éèẹẻẽêếềệểễ",
              @"óòọỏõôốồộổỗơớờợởỡ",
             @"úùụủũưứừựửữ",
             @"íìịỉĩ",
              @"đ",
              @"ýỳỵỷỹ",
             nil];
    
    
    
   bodau = [NSArray arrayWithObjects:@"A",@"E",@"O",@"U",@"I",@"D",@"Y",@"a",@"e",@"o",@"u",@"i",@"d",@"y",nil];
   
    return  self;
}

-(BOOL)characterInString:(NSString*)str withChar:(unichar)ch
{
    if(str==nil){
        return NO;
    }else{
        for (int k=0; k < str.length; k++) {
            unichar ch1 = [str characterAtIndex:k];
            if(ch1 == ch){
                return YES;
            }
        }
        return NO;
    }
}

-(NSString*)getNoMarkUnicode:(NSString*) s
  {
    NSMutableString* sOut =  [[NSMutableString alloc] initWithString:@""];
    if (s == Nil)
        return nil;
     
  
      
      for (int i=0; i<s.length; i++)
      {
          unichar ch = [s characterAtIndex:i];
         
          for (int j = 0; j < codau.count; j++)
          {
              if([self characterInString:[codau objectAtIndex:j] withChar:ch]){
                  ch = [bodau[j] characterAtIndex:0];
                  break;
              }
          }
          [sOut appendFormat:@"%c",ch];
      }
      
      return sOut;
}




	
-(NSString*) removeSpace:(NSString*) s
{
		if (s == nil)
            return nil;
    return [s stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(NSString*) getMixString:(NSString*) sIn
{
		int len = sIn.length;
		NSMutableString* sOut = [[NSMutableString alloc] initWithString:@""];
		NSString* sVNChars = [NSString stringWithFormat:@"%@%@", VN_CHARACTERS_1 , VN_CHARACTERS_2 ];
		for (int i = 0; i < 14 - len; i++) {
            int rand = arc4random() % sVNChars.length;
			[sOut appendString:[sVNChars substringWithRange:NSMakeRange(rand, 1)]];
		}
		return sOut;
	}

-(NSArray*) explodeString:(NSString*) s
{
    NSMutableArray* array = [[NSMutableArray alloc] init];

	    for(int i = 0; i < s.length; i++)
	    {
	        [array addObject:[s substringWithRange:NSMakeRange(i,1)]] ;
	    }
	    return array;
	}




-(NSArray*) getSuggestionFull:(NSString*) pAnswerShort
{
	
    NSMutableArray* mSuggestionFull = [[NSMutableArray alloc] init];
    
    int i = 0;
		/*
         String mSuggestionFull[] = new String[14];
         Random ran = new Random();
         int i = 0;
         
         for (i = 0; i < pAnswerShort.length(); i++) {
         mSuggestionFull[i] = "" + pAnswerShort.charAt(i);
         }
         
         int nextI = i + (mSuggestionFull.length - pAnswerShort.length()) / 2;
         String sTemp = "" + pAnswerShort;
         
         */
    for (i = 0; i < pAnswerShort.length; i++) {
			[mSuggestionFull addObject:[pAnswerShort substringWithRange:NSMakeRange(i, 1)]];
		}
		
		int nextI = i + (14 - pAnswerShort.length) / 2;
    
		NSMutableString* sTemp = [[ NSMutableString alloc] initWithString:pAnswerShort];
    
		for (; i < nextI; i++) {
			int j = -1;
			for (int t = 0; t < VN_CHARACTERS_1.length; t++) {
                NSString* ch = [VN_CHARACTERS_1 substringWithRange:NSMakeRange(t, 1)];
                
				if ([sTemp indexOf:ch] < 0) {
					j = t;
					break;
				}
			}
			if (j < 0) {
                j = arc4random() % VN_CHARACTERS_1.length;
				//j = ran.nextInt(107 + 3 * i) % VN_CHARACTERS_1.length();
			}
			//mSuggestionFull[i] = "" + VN_CHARACTERS_1.charAt(j);
                NSString* ch1= [VN_CHARACTERS_1 substringWithRange:NSMakeRange(j, 1)];
            [mSuggestionFull addObject:ch1];
            [sTemp appendString:ch1];
			//sTemp += mSuggestionFull[i];
		}
		
		for (; i < 14; i++) {
			int rndInt = arc4random() % VN_CHARACTERS_2.length;
			//mSuggestionFull[i] = "" + VN_CHARACTERS_2.charAt(rndInt);
            [mSuggestionFull addObject:[VN_CHARACTERS_2 substringWithRange:NSMakeRange(rndInt, 1)]];
		}
		
		//Mix string
		/*for (i = 0; i < mSuggestionFull.length; i++) {
			int rndInt = ran.nextInt(137 + 4 * i) % mSuggestionFull.length;
			if (rndInt == i) {
				rndInt = (rndInt + 3) % mSuggestionFull.length;
			}
			
			String temp = mSuggestionFull[i];
			mSuggestionFull[i] = mSuggestionFull[rndInt];
			mSuggestionFull[rndInt] = temp;
		}*/
    
    NSMutableArray* randomArray = [[NSMutableArray alloc] init];
   
  
    for (i = 0; i < mSuggestionFull.count; i++) {
        
        
        NSMutableDictionary* item = [[NSMutableDictionary alloc] init] ;
        
        
         NSInteger ranInt = arc4random();
        [item setObject:[NSNumber numberWithInteger:ranInt] forKey:@"randomkey"];
        [item setObject:[mSuggestionFull objectAtIndex:i] forKey:@"value"];
        
        [randomArray addObject:item];
        
        
    }
    
    randomArray = [randomArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
         NSNumber* aInt = [(NSDictionary*)a objectForKey:@"randomkey"] ;
         NSNumber* bInt = [(NSDictionary*)b objectForKey:@"randomkey"];
         return [(NSNumber*)aInt compare:(NSNumber*)bInt];
    }];

    
	
    mSuggestionFull = [[NSMutableArray alloc] init];
    for (i = 0; i < 14; i++) {
        [mSuggestionFull addObject:[[randomArray objectAtIndex:i] objectForKey:@"value"]];
    
    }
		
		return mSuggestionFull;
	}
/*
	
	public static String encodeAnswer(String sFullAnswer) {
		StringBuilder sEncoded = new StringBuilder();
		
		Random objRan = new Random();
		
		//Tạo một số random
		int iRand = Math.abs(objRan.nextInt(999999999));
		
		String sRand = String.valueOf(iRand);
		//1. Ghi độ dài của chuỗi random
		sEncoded.append(sRand.length());
		//2. Ghi chuỗi random
		sEncoded.append(sRand);
		
		//3. Ghi giá trị Encoding-Version
		sEncoded.append(Constant.ENCODING_VERSION);
		
		//Tạo bảng mã tiếng Việt + chữ số
		StringBuilder sVNChars = new StringBuilder();
		sVNChars.append(VN_CHARACTERS_1);
		sVNChars.append(VN_CHARACTERS_2);
		sVNChars.append(NUMBERS);
		for (int i = 0; i < VN_CONVERTION_CHARS.length / 2; i++) {
			sVNChars.append(VN_CONVERTION_CHARS[i][1]);
		}
		
		//Lấy 40 ký tự từ bảng mã 1 cách ngẫu nhiên
		StringBuilder sMixing = new StringBuilder();
		for (int i = 0; i < 40; i++) {
			int rndInt = objRan.nextInt(137 + 3 * i) % sVNChars.length();
			sMixing.append(sVNChars.charAt(rndInt));
		}
		
		//4. Ghi độ dài của chuỗi đáp án
		if (sFullAnswer.length() < 10) {
			sEncoded.append("0").append(sFullAnswer.length());
		} else {
			sEncoded.append(sFullAnswer.length());
		}
		
		int iArrAnswerPos[] = new int[sFullAnswer.length()];
		//Đẩy từng ký tự của chuỗi đáp án vào vị trí ngẫu nhiên trong 40 ký tự trộn
		for (int i = 0; i < iArrAnswerPos.length; i++) {
			int rndInt = -1;
			if (sFullAnswer.charAt(i) == ' ') {
				rndInt = sMixing.length() - 1;
			} else {
				while (true) {
					rndInt = objRan.nextInt(137 + 4 * i) % (sMixing.length() - 1);
					for (int j = 0; j < i; j++) {
						if (iArrAnswerPos[j] == rndInt) {
							rndInt = -1;
							break;
						}
					}
					if (rndInt >= 0) break;
				}
			}
			iArrAnswerPos[i] = rndInt;
			
			//Debug.show("rndInt", i + "; rndInt: " + rndInt +"; sTmp = " + sTmp);
			sMixing.replace(rndInt, rndInt + 1, "" + sFullAnswer.charAt(i));
			//5. Ghi vị trí của chuỗi đáp án
			if (rndInt < 10) {
				sEncoded.append("0").append(rndInt);
			} else {
				sEncoded.append(rndInt);
			}
		}
		//6. Ghi chuỗi hỗn hợp gồm đáp án và các ký tự trộn
		sEncoded.append(sMixing);
		//Debug.show("Encode", sEncoded.toString());
		
		return sEncoded.toString();
	}
	
	public static String decodeAnswer(String sEncodedAnswer) {
		String s = sEncodedAnswer;
		
		//1. Đọc độ dài chuỗi ngẫu nhiên
		int num1 = Integer.parseInt("" + s.charAt(0));
		
		//Debug.show("Decode", "num1 = " + num1);
		//Debug.show("Decode", "" + s);
		//2. Cắt bỏ chuỗi ngẫu nhiên
		s = s.substring(num1 + 1);
		
		//3. Đọc giá trị Encoding-Version
		int num2 = Integer.parseInt("" + s.charAt(0));
		s = s.substring(1);
		
		//4. Đọc độ dài của chuỗi đáp án
		int num3 = Integer.parseInt("" + s.charAt(0) + s.charAt(1));
		
		s = s.substring(2);
		
		//Debug.show("Decode", "num2 = " + num2 + "; s = " +s);
		int iArrPosition[] = new int[num3];
		
		//5. Đọc giá trị các vị trí của chuỗi đáp án
		for (int i = 0; i < iArrPosition.length; i++) {
			iArrPosition[i] = Integer.parseInt("" + s.charAt(2 * i) + s.charAt(2 * i + 1));
		}
		
		s = s.substring(2 * iArrPosition.length);
		
		String sOut = "";
		//6. Lấy chuỗi đáp án
		for (int i = 0; i < iArrPosition.length; i++) {
			sOut += s.charAt(iArrPosition[i]);
		}
		
		//Debug.show("Decode", sOut);
		
		return sOut;
	}
	
    public static String convertNumberToString(int n) {
        if (n < 10) return "000" + n;
        if (n < 100) return "00" + n;
        if (n < 100) return "00" + n;
        return "" + n;
    }
    
	public static String getNameStyle(String s) {
		if (s == null || s.trim().length() == 0) return "";
        String sOut = "";
        boolean needUpper = true;
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            if (ch == ' ' || ch == '\t') {
                needUpper = true;
            } else {
                if (needUpper) {
                    sOut += Character.toUpperCase(ch);
                    needUpper = false;
                } else {
                    sOut += Character.toLowerCase(ch);
                }
            }
        }
		return sOut;
	}
*/

@end
