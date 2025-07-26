unit TThread.Lock;

interface

uses
  System.SyncObjs;

type
  TThreadLockType = (tltMonitor, tltCriticalSection);

  TThreadLock = class
  private
    FLockType: TThreadLockType;
    FObject: TObject;
    FCriticalSection: TCriticalSection;
  public
    constructor Create(const ALockType: TThreadLockType = tltMonitor);
    destructor Destroy; override;

    procedure Acquire(const ATimeout: Cardinal = INFINITE);
    procedure Release;
    procedure Enter(const ATimeout: Cardinal = INFINITE);
    procedure Leave;
    procedure BeginRead(const ATimeout: Cardinal = INFINITE);
    procedure EndRead;
    procedure BeginWrite(const ATimeout: Cardinal = INFINITE);
    procedure EndWrite;
  end;

implementation

uses
  System.SysUtils;

constructor TThreadLock.Create(const ALockType: TThreadLockType = tltMonitor);
begin
  inherited Create;

  FLockType := ALockType;

  case FLockType of
    tltMonitor: FObject := TObject.Create;
    tltCriticalSection: FCriticalSection := TCriticalSection.Create;
  end;
end;

destructor TThreadLock.Destroy;
begin
  case FLockType of
    tltMonitor: FreeAndNil(FObject);
    tltCriticalSection: FreeAndNil(FCriticalSection);
  end;

  inherited Destroy;
end;

procedure TThreadLock.Acquire(const ATimeout: Cardinal = INFINITE);
begin
  case FLockType of
    tltMonitor: TMonitor.Enter(FObject, ATimeout);
    tltCriticalSection: begin
                          FCriticalSection.Acquire;
                          FCriticalSection.WaitFor(ATimeout);
                        end;
  end;
end;

procedure TThreadLock.Release;
begin
  case FLockType of
    tltMonitor: TMonitor.Exit(FObject);
    tltCriticalSection: FCriticalSection.Release;
  end;
end;

procedure TThreadLock.Enter(const ATimeout: Cardinal = INFINITE);
begin
  Acquire(ATimeout);
end;

procedure TThreadLock.Leave;
begin
  Release;
end;

procedure TThreadLock.BeginRead(const ATimeout: Cardinal = INFINITE);
begin
  Acquire(ATimeout);
end;

procedure TThreadLock.EndRead;
begin
  Release;
end;

procedure TThreadLock.BeginWrite(const ATimeout: Cardinal = INFINITE);
begin
  Acquire(ATimeout);
end;

procedure TThreadLock.EndWrite;
begin
  Release;
end;

end.
