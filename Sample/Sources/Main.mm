
int main(int argc, char *argv[])
{
	@autoreleasepool
	{
		_Log(@"%@", NSProcessInfo.processInfo.arguments);
		return UIApplicationMain(argc, argv, nil, @"AppDelegate");
	}
}
