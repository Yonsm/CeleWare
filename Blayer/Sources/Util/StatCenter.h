
#ifdef kAppStatKey
#import "MobClick.h"
#endif

//
NS_INLINE void StatStart(NSString *channeId = nil)
{
#ifdef kAppStatKey
	[MobClick startWithAppkey:kAppStatKey reportPolicy:BATCH channelId:channeId];
#endif
}

//
NS_INLINE void StatEvent(NSString *event, NSDictionary *attrs = nil)
{
#ifdef kAppStatKey
	if (attrs) [MobClick event:event attributes:attrs];
	else [MobClick event:event];
#endif
}

//
NS_INLINE void StatEvent(NSString *event, NSString *attr1, NSString *attr2)
{
#ifdef kAppStatKey
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:attr1, @"u", attr2, @"a", nil];
	StatEvent(event, attrs);
#endif
}

//
NS_INLINE void StatEvent(NSString *event, NSString *attr)
{
#ifdef kAppStatKey
	NSDictionary *attrs = [NSDictionary dictionaryWithObject:attr forKey:@"u"];
	StatEvent(event, attrs);
#endif
}

//
NS_INLINE void StatPageBegin(NSString *page)
{
#ifdef kAppStatKey
	[MobClick beginLogPageView:page];
#endif
	_Log(@"Enter Page: %@", page);
}

//
NS_INLINE void StatPageEnded(NSString *page)
{
	_Log(@"Leave Page: %@", page);
#ifdef kAppStatKey
	[MobClick endLogPageView:page];
#endif
}
