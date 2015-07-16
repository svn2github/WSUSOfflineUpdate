#include-once

; #INDEX# =======================================================================================================================
; Title .........: WinAPIFiles Constants UDF Library for AutoIt3
; AutoIt Version : 3.3.14.0
; Language ......: English
; Description ...: Constants that can be used with UDF library
; Author(s) .....: Yashied, Jpm
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================

; _WinAPI_BackupRead(), _WinAPI_BackupWrite()
Global Const $BACKUP_ALTERNATE_DATA = 0x00000004
Global Const $BACKUP_DATA = 0x00000001
Global Const $BACKUP_EA_DATA = 0x00000002
Global Const $BACKUP_LINK = 0x00000005
Global Const $BACKUP_OBJECT_ID = 0x00000007
Global Const $BACKUP_PROPERTY_DATA = 0x00000006
Global Const $BACKUP_REPARSE_DATA = 0x00000008
Global Const $BACKUP_SECURITY_DATA = 0x00000003
Global Const $BACKUP_SPARSE_BLOCK = 0x00000009
Global Const $BACKUP_TXFS_DATA = 0x0000000A

; _WinAPI_CopyFileEx(), _WinAPI_MoveFileEx()
Global Const $COPY_FILE_ALLOW_DECRYPTED_DESTINATION = 0x0008
Global Const $COPY_FILE_COPY_SYMLINK = 0x0800
Global Const $COPY_FILE_FAIL_IF_EXISTS = 0x0001
Global Const $COPY_FILE_NO_BUFFERING = 0x1000
Global Const $COPY_FILE_OPEN_SOURCE_FOR_WRITE = 0x0004
Global Const $COPY_FILE_RESTARTABLE = 0x0002

Global Const $MOVE_FILE_COPY_ALLOWED = 0x0002
Global Const $MOVE_FILE_CREATE_HARDLINK = 0x0010
Global Const $MOVE_FILE_DELAY_UNTIL_REBOOT = 0x0004
Global Const $MOVE_FILE_FAIL_IF_NOT_TRACKABLE = 0x0020
Global Const $MOVE_FILE_REPLACE_EXISTING = 0x0001
Global Const $MOVE_FILE_WRITE_THROUGH = 0x0008

Global Const $PROGRESS_CONTINUE = 0
Global Const $PROGRESS_CANCEL = 1
Global Const $PROGRESS_STOP = 2
Global Const $PROGRESS_QUIET = 3

; _WinAPI_CreateFileEx(), _WinAPI_SetFileAttributes(), _WinAPI_SetFileAttributes()
; Global Const $CREATE_NEW = 1
; Global Const $CREATE_ALWAYS = 2
; Global Const $OPEN_EXISTING = 3
; Global Const $OPEN_ALWAYS = 4
; Global Const $TRUNCATE_EXISTING = 5

; Global Const $GENERIC_ALL = 0x10000000
; Global Const $GENERIC_EXECUTE = 0x20000000
; Global Const $GENERIC_WRITE = 0x40000000
; Global Const $GENERIC_READ = 0x80000000

Global Const $FILE_APPEND_DATA = 0x0004
Global Const $FILE_DELETE_CHILD = 0x0040
Global Const $FILE_EXECUTE = 0x0020
Global Const $FILE_READ_ATTRIBUTES = 0x0080
Global Const $FILE_READ_DATA = 0x0001
Global Const $FILE_READ_EA = 0x0008
Global Const $FILE_WRITE_ATTRIBUTES = 0x0100
Global Const $FILE_WRITE_DATA = 0x0002
Global Const $FILE_WRITE_EA = 0x0010
Global Const $FILE_ADD_FILE = $FILE_WRITE_DATA
Global Const $FILE_ADD_SUBDIRECTORY = $FILE_APPEND_DATA
Global Const $FILE_CREATE_PIPE_INSTANCE = $FILE_APPEND_DATA
Global Const $FILE_LIST_DIRECTORY = $FILE_READ_DATA
Global Const $FILE_TRAVERSE = $FILE_EXECUTE
Global Const $FILE_ALL_ACCESS = 0x001F01FF ;  BitOR($STANDARD_RIGHTS_ALL, $FILE_APPEND_DATA, $FILE_DELETE_CHILD, $FILE_EXECUTE, $FILE_READ_ATTRIBUTES, $FILE_READ_DATA, $FILE_READ_EA, $FILE_WRITE_ATTRIBUTES, $FILE_WRITE_DATA, $FILE_WRITE_EA)

; Global Const $FILE_SHARE_READ = 0x01
; Global Const $FILE_SHARE_WRITE = 0x02
; Global Const $FILE_SHARE_DELETE = 0x04

; Global Const $FILE_ATTRIBUTE_READONLY = 0x00000001
; Global Const $FILE_ATTRIBUTE_HIDDEN = 0x00000002
; Global Const $FILE_ATTRIBUTE_SYSTEM = 0x00000004
; Global Const $FILE_ATTRIBUTE_DIRECTORY = 0x00000010
; Global Const $FILE_ATTRIBUTE_ARCHIVE = 0x00000020
; Global Const $FILE_ATTRIBUTE_DEVICE = 0x00000040
; Global Const $FILE_ATTRIBUTE_NORMAL = 0x00000080
; Global Const $FILE_ATTRIBUTE_TEMPORARY = 0x00000100
; Global Const $FILE_ATTRIBUTE_SPARSE_FILE = 0x00000200
; Global Const $FILE_ATTRIBUTE_REPARSE_POINT = 0x00000400
; Global Const $FILE_ATTRIBUTE_COMPRESSED = 0x00000800
; Global Const $FILE_ATTRIBUTE_OFFLINE = 0x00001000
; Global Const $FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x00002000
; Global Const $FILE_ATTRIBUTE_ENCRYPTED = 0x00004000

Global Const $FILE_FLAG_BACKUP_SEMANTICS = 0x02000000
Global Const $FILE_FLAG_DELETE_ON_CLOSE = 0x04000000
Global Const $FILE_FLAG_NO_BUFFERING = 0x20000000
Global Const $FILE_FLAG_OPEN_NO_RECALL = 0x00100000
Global Const $FILE_FLAG_OPEN_REPARSE_POINT = 0x00200000
Global Const $FILE_FLAG_OVERLAPPED = 0x40000000
Global Const $FILE_FLAG_POSIX_SEMANTICS = 0x0100000
Global Const $FILE_FLAG_RANDOM_ACCESS = 0x10000000
Global Const $FILE_FLAG_SEQUENTIAL_SCAN = 0x08000000
Global Const $FILE_FLAG_WRITE_THROUGH = 0x80000000

Global Const $SECURITY_ANONYMOUS = 0x00000000
Global Const $SECURITY_CONTEXT_TRACKING = 0x00040000
Global Const $SECURITY_DELEGATION = 0x00030000
Global Const $SECURITY_EFFECTIVE_ONLY = 0x00080000
Global Const $SECURITY_IDENTIFICATION = 0x00010000
Global Const $SECURITY_IMPERSONATION = 0x00020000

; _WinAPI_CreateFileMapping(), _WinAPI_OpenFileMapping()
; Moved in MemoryConstants.au3
; Global Const $PAGE_EXECUTE = 0x0010
; Global Const $PAGE_EXECUTE_READ = 0x0020
; Global Const $PAGE_EXECUTE_READWRITE = 0x0040
; Global Const $PAGE_EXECUTE_WRITECOPY = 0x0080
; Global Const $PAGE_GUARD = 0x0100
; Global Const $PAGE_NOACCESS = 0x0001
; Global Const $PAGE_NOCACHE = 0x0200
; Global Const $PAGE_READONLY = 0x0002
; Global Const $PAGE_READWRITE = 0x0004
; Global Const $PAGE_WRITECOMBINE = 0x0400
; Global Const $PAGE_WRITECOPY = 0x0008

Global Const $SEC_COMMIT = 0x08000000
Global Const $SEC_IMAGE = 0x01000000
Global Const $SEC_LARGE_PAGES = 0x80000000
Global Const $SEC_NOCACHE = 0x10000000
Global Const $SEC_RESERVE = 0x04000000
Global Const $SEC_WRITECOMBINE = 0x40000000

Global Const $SECTION_EXTEND_SIZE = 0x0010
Global Const $SECTION_MAP_EXECUTE = 0x0008
Global Const $SECTION_MAP_READ = 0x0004
Global Const $SECTION_MAP_WRITE = 0x0002
Global Const $SECTION_QUERY = 0x0001
Global Const $SECTION_ALL_ACCESS = 0x001F001F ; BitOR($STANDARD_RIGHTS_REQUIRED, $SECTION_EXTEND_SIZE, $SECTION_MAP_EXECUTE, $SECTION_MAP_READ, $SECTION_MAP_WRITE, $SECTION_QUERY)

Global Const $FILE_MAP_COPY = 0x0001
Global Const $FILE_MAP_EXECUTE = 0x0020
Global Const $FILE_MAP_READ = 0x0004
Global Const $FILE_MAP_WRITE = 0x0002
Global Const $FILE_MAP_ALL_ACCESS = $SECTION_ALL_ACCESS

; _WinAPI_DefineDosDevice()
Global Const $DDD_EXACT_MATCH_ON_REMOVE = 0x04
Global Const $DDD_NO_BROADCAST_SYSTEM = 0x08
Global Const $DDD_RAW_TARGET_PATH = 0x01
Global Const $DDD_REMOVE_DEFINITION = 0x02

; _WinAPI_DeviceIoControl()
Global Const $FSCTL_ALLOW_EXTENDED_DASD_IO = 0x00090083
Global Const $FSCTL_CREATE_OR_GET_OBJECT_ID = 0x000900C0
Global Const $FSCTL_CREATE_USN_JOURNAL = 0x000900E7
Global Const $FSCTL_DELETE_OBJECT_ID = 0x000900A0
Global Const $FSCTL_DELETE_REPARSE_POINT = 0x000900AC
Global Const $FSCTL_DELETE_USN_JOURNAL = 0x000900F8
Global Const $FSCTL_DISMOUNT_VOLUME = 0x00090020
Global Const $FSCTL_DUMP_PROPERTY_DATA = 0x00090097
Global Const $FSCTL_ENABLE_UPGRADE = 0x000980D0
Global Const $FSCTL_ENCRYPTION_FSCTL_IO = 0x000900DB
Global Const $FSCTL_ENUM_USN_DATA = 0x000900B3
Global Const $FSCTL_EXTEND_VOLUME = 0x000900F0
Global Const $FSCTL_FILESYSTEM_GET_STATISTICS = 0x00090060
Global Const $FSCTL_FIND_FILES_BY_SID = 0x0009008F
Global Const $FSCTL_GET_COMPRESSION = 0x0009003C
Global Const $FSCTL_GET_NTFS_FILE_RECORD = 0x00090068
Global Const $FSCTL_GET_NTFS_VOLUME_DATA = 0x00090064
Global Const $FSCTL_GET_OBJECT_ID = 0x0009009C
Global Const $FSCTL_GET_REPARSE_POINT = 0x000900A8
Global Const $FSCTL_GET_RETRIEVAL_POINTERS = 0x00090073
Global Const $FSCTL_GET_VOLUME_BITMAP = 0x0009006F
Global Const $FSCTL_HSM_DATA = 0x0009C113
Global Const $FSCTL_HSM_MSG = 0x0009C108
Global Const $FSCTL_INVALIDATE_VOLUMES = 0x00090054
Global Const $FSCTL_IS_PATHNAME_VALID = 0x0009002C
Global Const $FSCTL_IS_VOLUME_DIRTY = 0x00090078
Global Const $FSCTL_IS_VOLUME_MOUNTED = 0x00090028
Global Const $FSCTL_LOCK_VOLUME = 0x00090018
Global Const $FSCTL_MARK_AS_SYSTEM_HIVE = 0x0009004F
Global Const $FSCTL_MARK_HANDLE = 0x000900FC
Global Const $FSCTL_MARK_VOLUME_DIRTY = 0x00090030
Global Const $FSCTL_MOVE_FILE = 0x00090074
Global Const $FSCTL_OPBATCH_ACK_CLOSE_PENDING = 0x00090010
Global Const $FSCTL_OPLOCK_BREAK_ACK_NO_2 = 0x00090050
Global Const $FSCTL_OPLOCK_BREAK_ACKNOWLEDGE = 0x0009000C
Global Const $FSCTL_OPLOCK_BREAK_NOTIFY = 0x00090014
Global Const $FSCTL_QUERY_ALLOCATED_RANGES = 0x000940CF
Global Const $FSCTL_QUERY_FAT_BPB = 0x00090058
Global Const $FSCTL_QUERY_RETRIEVAL_POINTERS = 0x0009003B
Global Const $FSCTL_QUERY_USN_JOURNAL = 0x000900F4
Global Const $FSCTL_READ_FILE_USN_DATA = 0x000900EB
Global Const $FSCTL_READ_PROPERTY_DATA = 0x00090087
Global Const $FSCTL_READ_RAW_ENCRYPTED = 0x000900E3
Global Const $FSCTL_READ_USN_JOURNAL = 0x000900BB
Global Const $FSCTL_RECALL_FILE = 0x00090117
Global Const $FSCTL_REQUEST_BATCH_OPLOCK = 0x00090008
Global Const $FSCTL_REQUEST_FILTER_OPLOCK = 0x0009005C
Global Const $FSCTL_REQUEST_OPLOCK_LEVEL_1 = 0x00090000
Global Const $FSCTL_REQUEST_OPLOCK_LEVEL_2 = 0x00090004
Global Const $FSCTL_SECURITY_ID_CHECK = 0x000940B7
Global Const $FSCTL_SET_COMPRESSION = 0x0009C040
Global Const $FSCTL_SET_ENCRYPTION = 0x000900D7
Global Const $FSCTL_SET_OBJECT_ID = 0x00090098
Global Const $FSCTL_SET_OBJECT_ID_EXTENDED = 0x000900BC
Global Const $FSCTL_SET_REPARSE_POINT = 0x000900A4
Global Const $FSCTL_SET_SPARSE = 0x000900C4
Global Const $FSCTL_SET_ZERO_DATA = 0x000980C8
Global Const $FSCTL_SIS_COPYFILE = 0x00090100
Global Const $FSCTL_SIS_LINK_FILES = 0x0009C104
Global Const $FSCTL_UNLOCK_VOLUME = 0x0009001C
Global Const $FSCTL_WRITE_PROPERTY_DATA = 0x0009008B
Global Const $FSCTL_WRITE_RAW_ENCRYPTED = 0x000900DF
Global Const $FSCTL_WRITE_USN_CLOSE_RECORD = 0x000900EF

Global Const $IOCTL_AACS_END_SESSION = 0x003350CC
Global Const $IOCTL_AACS_GENERATE_BINDING_NONCE = 0x0033D0F0
Global Const $IOCTL_AACS_GET_CERTIFICATE = 0x003350D4
Global Const $IOCTL_AACS_GET_CHALLENGE_KEY = 0x003350D8
Global Const $IOCTL_AACS_READ_BINDING_NONCE = 0x003350EC
Global Const $IOCTL_AACS_READ_MEDIA_ID = 0x003350E8
Global Const $IOCTL_AACS_READ_MEDIA_KEY_BLOCK = 0x003350C4
Global Const $IOCTL_AACS_READ_MEDIA_KEY_BLOCK_SIZE = 0x003350C0
Global Const $IOCTL_AACS_READ_SERIAL_NUMBER = 0x003350E4
Global Const $IOCTL_AACS_READ_VOLUME_ID = 0x003350E0
Global Const $IOCTL_AACS_SEND_CERTIFICATE = 0x003350D0
Global Const $IOCTL_AACS_SEND_CHALLENGE_KEY = 0x003350DC
Global Const $IOCTL_AACS_START_SESSION = 0x003350C8

Global Const $IOCTL_ATA_PASS_THROUGH = 0x0004D02C
Global Const $IOCTL_ATA_PASS_THROUGH_DIRECT = 0x0004D030

Global Const $IOCTL_CDROM_CHECK_VERIFY = 0x00024800
Global Const $IOCTL_CDROM_DISK_TYPE = 0x00020040
Global Const $IOCTL_CDROM_EJECT_MEDIA = 0x00024808
Global Const $IOCTL_CDROM_FIND_NEW_DEVICES = 0x00024818
Global Const $IOCTL_CDROM_GET_CONFIGURATION = 0x00024058
Global Const $IOCTL_CDROM_GET_CONTROL = 0x00024034
Global Const $IOCTL_CDROM_GET_DRIVE_GEOMETRY = 0x0002404C
Global Const $IOCTL_CDROM_GET_DRIVE_GEOMETRY_EX = 0x00024050
Global Const $IOCTL_CDROM_GET_LAST_SESSION = 0x00024038
Global Const $IOCTL_CDROM_GET_VOLUME = 0x00024014
Global Const $IOCTL_CDROM_LOAD_MEDIA = 0x0002480C
Global Const $IOCTL_CDROM_MEDIA_REMOVAL = 0x00024804
Global Const $IOCTL_CDROM_PAUSE_AUDIO = 0x0002400C
Global Const $IOCTL_CDROM_PLAY_AUDIO_MSF = 0x00024018
Global Const $IOCTL_CDROM_RAW_READ = 0x0002403E
Global Const $IOCTL_CDROM_READ_Q_CHANNEL = 0x0002402C
Global Const $IOCTL_CDROM_READ_TOC = 0x00024000
Global Const $IOCTL_CDROM_READ_TOC_EX = 0x00024054
Global Const $IOCTL_CDROM_RELEASE = 0x00024814
Global Const $IOCTL_CDROM_RESERVE = 0x00024810
Global Const $IOCTL_CDROM_RESUME_AUDIO = 0x00024010
Global Const $IOCTL_CDROM_SEEK_AUDIO_MSF = 0x00024004
Global Const $IOCTL_CDROM_SET_VOLUME = 0x00024028
Global Const $IOCTL_CDROM_STOP_AUDIO = 0x00024008
Global Const $IOCTL_CDROM_UNLOAD_DRIVER = 0x00025008

Global Const $IOCTL_DISK_CHECK_VERIFY = 0x00074800
Global Const $IOCTL_DISK_CONTROLLER_NUMBER = 0x00070044
Global Const $IOCTL_DISK_CREATE_DISK = 0x0007C058
Global Const $IOCTL_DISK_DELETE_DRIVE_LAYOUT = 0x0007C100
Global Const $IOCTL_DISK_EJECT_MEDIA = 0x00074808
Global Const $IOCTL_DISK_FIND_NEW_DEVICES = 0x00074818
Global Const $IOCTL_DISK_FORMAT_TRACKS = 0x0007C018
Global Const $IOCTL_DISK_FORMAT_TRACKS_EX = 0x0007C02C
Global Const $IOCTL_DISK_GET_CACHE_INFORMATION = 0x000740D4
Global Const $IOCTL_DISK_GET_DRIVE_GEOMETRY = 0x00070000
Global Const $IOCTL_DISK_GET_DRIVE_GEOMETRY_EX = 0x000700A0
Global Const $IOCTL_DISK_GET_DRIVE_LAYOUT = 0x0007400C
Global Const $IOCTL_DISK_GET_DRIVE_LAYOUT_EX = 0x00070050
Global Const $IOCTL_DISK_GET_LENGTH_INFO = 0x0007405C
Global Const $IOCTL_DISK_GET_MEDIA_TYPES = 0x00070C00
Global Const $IOCTL_DISK_GET_PARTITION_INFO = 0x00074004
Global Const $IOCTL_DISK_GET_PARTITION_INFO_EX = 0x00070048
Global Const $IOCTL_DISK_GET_WRITE_CACHE_STATE = 0x000740DC
Global Const $IOCTL_DISK_GROW_PARTITION = 0x0007C0D0
Global Const $IOCTL_DISK_HISTOGRAM_DATA = 0x00070034
Global Const $IOCTL_DISK_HISTOGRAM_RESET = 0x00070038
Global Const $IOCTL_DISK_HISTOGRAM_STRUCTURE = 0x00070030
Global Const $IOCTL_DISK_INTERNAL_CLEAR_VERIFY = 0x00070407
Global Const $IOCTL_DISK_INTERNAL_SET_NOTIFY = 0x00070408
Global Const $IOCTL_DISK_INTERNAL_SET_VERIFY = 0x00070403
Global Const $IOCTL_DISK_IS_WRITABLE = 0x00070024
Global Const $IOCTL_DISK_LOAD_MEDIA = 0x0007480C
Global Const $IOCTL_DISK_LOGGING = 0x00070028
Global Const $IOCTL_DISK_MEDIA_REMOVAL = 0x00074804
Global Const $IOCTL_DISK_PERFORMANCE = 0x00070020
Global Const $IOCTL_DISK_PERFORMANCE_OFF = 0x00070060
Global Const $IOCTL_DISK_REASSIGN_BLOCKS = 0x0007C01C
Global Const $IOCTL_DISK_RELEASE = 0x00074814
Global Const $IOCTL_DISK_REQUEST_DATA = 0x00070040
Global Const $IOCTL_DISK_REQUEST_STRUCTURE = 0x0007003C
Global Const $IOCTL_DISK_RESERVE = 0x00074810
Global Const $IOCTL_DISK_SET_CACHE_INFORMATION = 0x0007C0D8
Global Const $IOCTL_DISK_SET_DRIVE_LAYOUT = 0x0007C010
Global Const $IOCTL_DISK_SET_DRIVE_LAYOUT_EX = 0x0007C054
Global Const $IOCTL_DISK_SET_PARTITION_INFO = 0x0007C008
Global Const $IOCTL_DISK_SET_PARTITION_INFO_EX = 0x0007C04C
Global Const $IOCTL_DISK_UPDATE_DRIVE_SIZE = 0x0007C0C8
Global Const $IOCTL_DISK_UPDATE_PROPERTIES = 0x00070140
Global Const $IOCTL_DISK_VERIFY = 0x00070014

Global Const $IOCTL_DVD_END_SESSION = 0x0033500C
Global Const $IOCTL_DVD_GET_REGION = 0x00335014
Global Const $IOCTL_DVD_READ_KEY = 0x00335004
Global Const $IOCTL_DVD_READ_STRUCTURE = 0x00335140
Global Const $IOCTL_DVD_SEND_KEY = 0x00335008
Global Const $IOCTL_DVD_SEND_KEY2 = 0x0033D018
Global Const $IOCTL_DVD_SET_READ_AHEAD = 0x00335010
Global Const $IOCTL_DVD_START_SESSION = 0x00335000

Global Const $IOCTL_MOUNTDEV_LINK_CREATED = 0x004D0010
Global Const $IOCTL_MOUNTDEV_LINK_DELETED = 0x004D0014
Global Const $IOCTL_MOUNTDEV_QUERY_STABLE_GUID = 0x004D0018
Global Const $IOCTL_MOUNTDEV_QUERY_SUGGESTED_LINK_NAME = 0x004D000C
Global Const $IOCTL_MOUNTDEV_QUERY_UNIQUE_ID = 0x004D0000
Global Const $IOCTL_MOUNTDEV_UNIQUE_ID_CHANGE_NOTIFY = 0x004D0004

Global Const $IOCTL_MOUNTMGR_AUTO_DL_ASSIGNMENTS = 0x006DC014
Global Const $IOCTL_MOUNTMGR_CHANGE_NOTIFY = 0x006D4020
Global Const $IOCTL_MOUNTMGR_CHECK_UNPROCESSED_VOLUMES = 0x006D4028
Global Const $IOCTL_MOUNTMGR_CREATE_POINT = 0x006DC000
Global Const $IOCTL_MOUNTMGR_DELETE_POINTS = 0x006DC004
Global Const $IOCTL_MOUNTMGR_DELETE_POINTS_DBONLY = 0x006DC00C
Global Const $IOCTL_MOUNTMGR_KEEP_LINKS_WHEN_OFFLINE = 0x006DC024
Global Const $IOCTL_MOUNTMGR_NEXT_DRIVE_LETTER = 0x006DC010
Global Const $IOCTL_MOUNTMGR_QUERY_DOS_VOLUME_PATH = 0x006D0030
Global Const $IOCTL_MOUNTMGR_QUERY_DOS_VOLUME_PATHS = 0x006D0034
Global Const $IOCTL_MOUNTMGR_QUERY_POINTS = 0x006D0008
Global Const $IOCTL_MOUNTMGR_VOLUME_ARRIVAL_NOTIFICATION = 0x006D402C
Global Const $IOCTL_MOUNTMGR_VOLUME_MOUNT_POINT_CREATED = 0x006DC018
Global Const $IOCTL_MOUNTMGR_VOLUME_MOUNT_POINT_DELETED = 0x006DC01C

Global Const $IOCTL_SCSI_GET_INQUIRY_DATA = 0x0004100C
Global Const $IOCTL_SCSI_GET_CAPABILITIES = 0x00041010
Global Const $IOCTL_SCSI_GET_ADDRESS = 0x00041018
Global Const $IOCTL_SCSI_MINIPORT = 0x0004D008
Global Const $IOCTL_SCSI_PASS_THROUGH = 0x0004D004
Global Const $IOCTL_SCSI_PASS_THROUGH_DIRECT = 0x0004D014
Global Const $IOCTL_SCSI_RESCAN_BUS = 0x0004101C

Global Const $IOCTL_STORAGE_BREAK_RESERVATION = 0x002D5014
Global Const $IOCTL_STORAGE_CHECK_VERIFY = 0x002D4800
Global Const $IOCTL_STORAGE_CHECK_VERIFY2 = 0x002D0800
Global Const $IOCTL_STORAGE_EJECT_MEDIA = 0x002D4808
Global Const $IOCTL_STORAGE_EJECTION_CONTROL = 0x002D0940
Global Const $IOCTL_STORAGE_FIND_NEW_DEVICES = 0x002D4818
Global Const $IOCTL_STORAGE_GET_DEVICE_NUMBER = 0x002D1080
Global Const $IOCTL_STORAGE_GET_HOTPLUG_INFO = 0x002D0C14
Global Const $IOCTL_STORAGE_GET_MEDIA_SERIAL_NUMBER = 0x002D0C10
Global Const $IOCTL_STORAGE_GET_MEDIA_TYPES = 0x002D0C00
Global Const $IOCTL_STORAGE_GET_MEDIA_TYPES_EX = 0x002D0C04
Global Const $IOCTL_STORAGE_LOAD_MEDIA = 0x002D480C
Global Const $IOCTL_STORAGE_LOAD_MEDIA2 = 0x002D080C
Global Const $IOCTL_STORAGE_MANAGE_DATA_SET_ATTRIBUTES = 0x002D9404
Global Const $IOCTL_STORAGE_MCN_CONTROL = 0x002D0944
Global Const $IOCTL_STORAGE_MEDIA_REMOVAL = 0x002D4804
Global Const $IOCTL_STORAGE_PERSISTENT_RESERVE_IN = 0x002D5018
Global Const $IOCTL_STORAGE_PERSISTENT_RESERVE_OUT = 0x002D501C
Global Const $IOCTL_STORAGE_PREDICT_FAILURE = 0x002D1100
Global Const $IOCTL_STORAGE_QUERY_PROPERTY = 0x002D1400
Global Const $IOCTL_STORAGE_RELEASE = 0x002D4814
Global Const $IOCTL_STORAGE_RESERVE = 0x002D4810
Global Const $IOCTL_STORAGE_RESET_BUS = 0x002D5000
Global Const $IOCTL_STORAGE_RESET_DEVICE = 0x002D5004
Global Const $IOCTL_STORAGE_SET_HOTPLUG_INFO = 0x002DCC18
Global Const $IOCTL_STORAGE_SET_READ_AHEAD = 0x002D4400

Global Const $IOCTL_VOLUME_GET_GPT_ATTRIBUTES = 0x00560038
Global Const $IOCTL_VOLUME_GET_VOLUME_DISK_EXTENTS = 0x00560000
Global Const $IOCTL_VOLUME_IS_CLUSTERED = 0x00560030
Global Const $IOCTL_VOLUME_IS_IO_CAPABLE = 0x00560014
Global Const $IOCTL_VOLUME_IS_OFFLINE = 0x00560010
Global Const $IOCTL_VOLUME_IS_PARTITION = 0x00560028
Global Const $IOCTL_VOLUME_LOGICAL_TO_PHYSICAL = 0x00560020
Global Const $IOCTL_VOLUME_OFFLINE = 0x0056C00C
Global Const $IOCTL_VOLUME_ONLINE = 0x0056C008
Global Const $IOCTL_VOLUME_PHYSICAL_TO_LOGICAL = 0x00560024
Global Const $IOCTL_VOLUME_QUERY_FAILOVER_SET = 0x00560018
Global Const $IOCTL_VOLUME_QUERY_VOLUME_NUMBER = 0x0056001C
Global Const $IOCTL_VOLUME_READ_PLEX = 0x0056402E
Global Const $IOCTL_VOLUME_SET_GPT_ATTRIBUTES = 0x00560034
Global Const $IOCTL_VOLUME_SUPPORTS_ONLINE_OFFLINE = 0x00560004

Global Const $SMART_GET_VERSION = 0x00074080
Global Const $SMART_RCV_DRIVE_DATA = 0x0007C088
Global Const $SMART_SEND_DRIVE_COMMAND = 0x0007C084

; _WinAPI_FileEncryptionStatus()
Global Const $FILE_ENCRYPTABLE = 0
Global Const $FILE_IS_ENCRYPTED = 1
Global Const $FILE_READ_ONLY = 8
Global Const $FILE_ROOT_DIR = 3
Global Const $FILE_SYSTEM_ATTR = 2
Global Const $FILE_SYSTEM_DIR = 4
Global Const $FILE_SYSTEM_NOT_SUPPORT = 6
Global Const $FILE_UNKNOWN = 5
Global Const $FILE_USER_DISALLOWED = 7

; _WinAPI_GetBinaryType()
Global Const $SCS_32BIT_BINARY = 0
Global Const $SCS_64BIT_BINARY = 6
Global Const $SCS_DOS_BINARY = 1
Global Const $SCS_OS216_BINARY = 5
Global Const $SCS_PIF_BINARY = 3
Global Const $SCS_POSIX_BINARY = 4
Global Const $SCS_WOW_BINARY = 2

; _WinAPI_GetDriveBusType()
Global Const $DRIVE_BUS_TYPE_UNKNOWN = 0x00
Global Const $DRIVE_BUS_TYPE_SCSI = 0x01
Global Const $DRIVE_BUS_TYPE_ATAPI = 0x02
Global Const $DRIVE_BUS_TYPE_ATA = 0x03
Global Const $DRIVE_BUS_TYPE_1394 = 0x04
Global Const $DRIVE_BUS_TYPE_SSA = 0x05
Global Const $DRIVE_BUS_TYPE_FIBRE = 0x06
Global Const $DRIVE_BUS_TYPE_USB = 0x07
Global Const $DRIVE_BUS_TYPE_RAID = 0x08
Global Const $DRIVE_BUS_TYPE_ISCSI = 0x09
Global Const $DRIVE_BUS_TYPE_SAS = 0x0A
Global Const $DRIVE_BUS_TYPE_SATA = 0x0B
Global Const $DRIVE_BUS_TYPE_SD = 0x0C
Global Const $DRIVE_BUS_TYPE_MMC = 0x0D

; _WinAPI_GetDriveType()
Global Const $DRIVE_UNKNOWN = 0
Global Const $DRIVE_NO_ROOT_DIR = 1
Global Const $DRIVE_REMOVABLE = 2
Global Const $DRIVE_FIXED = 3
Global Const $DRIVE_REMOTE = 4
Global Const $DRIVE_CDROM = 5
Global Const $DRIVE_RAMDISK = 6

; _WinAPI_GetFileType()
Global Const $FILE_TYPE_CHAR = 0x0002
Global Const $FILE_TYPE_DISK = 0x0001
Global Const $FILE_TYPE_PIPE = 0x0003
Global Const $FILE_TYPE_REMOTE = 0x8000
Global Const $FILE_TYPE_UNKNOWN = 0x0000

; _WinAPI_GetFinalPathNameByHandle()
Global Const $FILE_NAME_NORMALIZED = 0x0
Global Const $FILE_NAME_OPENED = 0x8

Global Const $VOLUME_NAME_DOS = 0x0
Global Const $VOLUME_NAME_GUID = 0x1
Global Const $VOLUME_NAME_NONE = 0x4
Global Const $VOLUME_NAME_NT = 0x2

; _WinAPI_GetPEType()
Global Const $IMAGE_FILE_MACHINE_UNKNOWN = 0x0000
Global Const $IMAGE_FILE_MACHINE_AM33 = 0x01D3
Global Const $IMAGE_FILE_MACHINE_AMD64 = 0x8664
Global Const $IMAGE_FILE_MACHINE_ARM = 0x01C0
Global Const $IMAGE_FILE_MACHINE_EBC = 0x0EBC
Global Const $IMAGE_FILE_MACHINE_I386 = 0x014C
Global Const $IMAGE_FILE_MACHINE_IA64 = 0x0200
Global Const $IMAGE_FILE_MACHINE_M32R = 0x9041
Global Const $IMAGE_FILE_MACHINE_MIPS16 = 0x0266
Global Const $IMAGE_FILE_MACHINE_MIPSFPU = 0x0366
Global Const $IMAGE_FILE_MACHINE_MIPSFPU16 = 0x0466
Global Const $IMAGE_FILE_MACHINE_POWERPC = 0x01F0
Global Const $IMAGE_FILE_MACHINE_POWERPCFP = 0x01F1
Global Const $IMAGE_FILE_MACHINE_R4000 = 0x0166
Global Const $IMAGE_FILE_MACHINE_SH3 = 0x01A2
Global Const $IMAGE_FILE_MACHINE_SH3DSP = 0x01A3
Global Const $IMAGE_FILE_MACHINE_SH4 = 0x01A6
Global Const $IMAGE_FILE_MACHINE_SH5 = 0x01A8
Global Const $IMAGE_FILE_MACHINE_THUMB = 0x01C2
Global Const $IMAGE_FILE_MACHINE_WCEMIPSV2 = 0x0169

; _WinAPI_GetVolumeInformation(), _WinAPI_GetVolumeInformationByHandle()
Global Const $FILE_CASE_PRESERVED_NAMES = 0x00000002
Global Const $FILE_CASE_SENSITIVE_SEARCH = 0x00000001
Global Const $FILE_FILE_COMPRESSION = 0x00000010
Global Const $FILE_NAMED_STREAMS = 0x00040000
Global Const $FILE_PERSISTENT_ACLS = 0x00000008
Global Const $FILE_READ_ONLY_VOLUME = 0x00080000
Global Const $FILE_SEQUENTIAL_WRITE_ONCE = 0x00100000
Global Const $FILE_SUPPORTS_ENCRYPTION = 0x00020000
Global Const $FILE_SUPPORTS_EXTENDED_ATTRIBUTES = 0x00800000
Global Const $FILE_SUPPORTS_HARD_LINKS = 0x00400000
Global Const $FILE_SUPPORTS_OBJECT_IDS = 0x00010000
Global Const $FILE_SUPPORTS_OPEN_BY_FILE_ID = 0x01000000
Global Const $FILE_SUPPORTS_REPARSE_POINTS = 0x00000080
Global Const $FILE_SUPPORTS_SPARSE_FILES = 0x00000040
Global Const $FILE_SUPPORTS_TRANSACTIONS = 0x00200000
Global Const $FILE_SUPPORTS_USN_JOURNAL = 0x02000000
Global Const $FILE_UNICODE_ON_DISK = 0x00000004
Global Const $FILE_VOLUME_IS_COMPRESSED = 0x00008000
Global Const $FILE_VOLUME_QUOTAS = 0x00000020

; _WinAPI_IOCTL()
Global Const $FILE_DEVICE_8042_PORT = 0x0027
Global Const $FILE_DEVICE_ACPI = 0x0032
Global Const $FILE_DEVICE_BATTERY = 0x0029
Global Const $FILE_DEVICE_BEEP = 0x0001
Global Const $FILE_DEVICE_BUS_EXTENDER = 0x002A
Global Const $FILE_DEVICE_CD_ROM = 0x0002
Global Const $FILE_DEVICE_CD_ROM_FILE_SYSTEM = 0x0003
Global Const $FILE_DEVICE_CHANGER = 0x0030
Global Const $FILE_DEVICE_CONTROLLER = 0x0004
Global Const $FILE_DEVICE_DATALINK = 0x0005
Global Const $FILE_DEVICE_DFS = 0x0006
Global Const $FILE_DEVICE_DFS_FILE_SYSTEM = 0x0035
Global Const $FILE_DEVICE_DFS_VOLUME = 0x0036
Global Const $FILE_DEVICE_DISK = 0x0007
Global Const $FILE_DEVICE_DISK_FILE_SYSTEM = 0x0008
Global Const $FILE_DEVICE_DVD = 0x0033
Global Const $FILE_DEVICE_FILE_SYSTEM = 0x0009
Global Const $FILE_DEVICE_FIPS = 0x003A
Global Const $FILE_DEVICE_FULLSCREEN_VIDEO = 0x0034
Global Const $FILE_DEVICE_INPORT_PORT = 0x000A
Global Const $FILE_DEVICE_KEYBOARD = 0x000B
Global Const $FILE_DEVICE_KS = 0x002F
Global Const $FILE_DEVICE_KSEC = 0x0039
Global Const $FILE_DEVICE_MAILSLOT = 0x000C
Global Const $FILE_DEVICE_MASS_STORAGE = 0x002D
Global Const $FILE_DEVICE_MIDI_IN = 0x000D
Global Const $FILE_DEVICE_MIDI_OUT = 0x000E
Global Const $FILE_DEVICE_MODEM = 0x002B
Global Const $FILE_DEVICE_MOUSE = 0x000F
Global Const $FILE_DEVICE_MULTI_UNC_PROVIDER = 0x0010
Global Const $FILE_DEVICE_NAMED_PIPE = 0x0011
Global Const $FILE_DEVICE_NETWORK = 0x0012
Global Const $FILE_DEVICE_NETWORK_BROWSER = 0x0013
Global Const $FILE_DEVICE_NETWORK_FILE_SYSTEM = 0x0014
Global Const $FILE_DEVICE_NETWORK_REDIRECTOR = 0x0028
Global Const $FILE_DEVICE_NULL = 0x0015
Global Const $FILE_DEVICE_PARALLEL_PORT = 0x0016
Global Const $FILE_DEVICE_PHYSICAL_NETCARD = 0x0017
Global Const $FILE_DEVICE_PRINTER = 0x0018
Global Const $FILE_DEVICE_SCANNER = 0x0019
Global Const $FILE_DEVICE_SCREEN = 0x001C
Global Const $FILE_DEVICE_SERENUM = 0x0037
Global Const $FILE_DEVICE_SERIAL_MOUSE_PORT = 0x001A
Global Const $FILE_DEVICE_SERIAL_PORT = 0x001B
Global Const $FILE_DEVICE_SMARTCARD = 0x0031
Global Const $FILE_DEVICE_SMB = 0x002E
Global Const $FILE_DEVICE_SOUND = 0x001D
Global Const $FILE_DEVICE_STREAMS = 0x001E
Global Const $FILE_DEVICE_TAPE = 0x001F
Global Const $FILE_DEVICE_TAPE_FILE_SYSTEM = 0x0020
Global Const $FILE_DEVICE_TERMSRV = 0x0038
Global Const $FILE_DEVICE_TRANSPORT = 0x0021
Global Const $FILE_DEVICE_UNKNOWN = 0x0022
Global Const $FILE_DEVICE_VDM = 0x002C
Global Const $FILE_DEVICE_VIDEO = 0x0023
Global Const $FILE_DEVICE_VIRTUAL_DISK = 0x0024
Global Const $FILE_DEVICE_WAVE_IN = 0x0025
Global Const $FILE_DEVICE_WAVE_OUT = 0x0026

Global Const $FILE_ANY_ACCESS = 0x00
Global Const $FILE_SPECIAL_ACCESS = $FILE_ANY_ACCESS
Global Const $FILE_READ_ACCESS = 0x01
Global Const $FILE_WRITE_ACCESS = 0x02

Global Const $METHOD_BUFFERED = 0
Global Const $METHOD_IN_DIRECT = 1
Global Const $METHOD_OUT_DIRECT = 2
Global Const $METHOD_NEITHER = 3

; _WinAPI_ReadDirectoryChanges()
Global Const $FILE_NOTIFY_CHANGE_FILE_NAME = 0x0001
Global Const $FILE_NOTIFY_CHANGE_DIR_NAME = 0x0002
Global Const $FILE_NOTIFY_CHANGE_ATTRIBUTES = 0x0004
Global Const $FILE_NOTIFY_CHANGE_SIZE = 0x0008
Global Const $FILE_NOTIFY_CHANGE_LAST_WRITE = 0x0010
Global Const $FILE_NOTIFY_CHANGE_LAST_ACCESS = 0x0020
Global Const $FILE_NOTIFY_CHANGE_CREATION = 0x0040
Global Const $FILE_NOTIFY_CHANGE_SECURITY = 0x0100

Global Const $FILE_ACTION_ADDED = 0x0001
Global Const $FILE_ACTION_REMOVED = 0x0002
Global Const $FILE_ACTION_MODIFIED = 0x0003
Global Const $FILE_ACTION_RENAMED_OLD_NAME = 0x0004
Global Const $FILE_ACTION_RENAMED_NEW_NAME = 0x0005

; _WinAPI_ReplaceFile()
Global Const $REPLACEFILE_WRITE_THROUGH = 0x01
Global Const $REPLACEFILE_IGNORE_MERGE_ERRORS = 0x02
Global Const $REPLACEFILE_IGNORE_ACL_ERRORS = 0x04

; _WinAPI_SetSearchPathMode()
Global Const $BASE_SEARCH_PATH_ENABLE_SAFE_SEARCHMODE = 0x00000001
Global Const $BASE_SEARCH_PATH_DISABLE_SAFE_SEARCHMODE = 0x00010000
Global Const $BASE_SEARCH_PATH_PERMANENT = 0x00008000
; ===============================================================================================================================
