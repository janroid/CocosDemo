local PhpInfo = {}

function PhpInfo.init(data)
    PhpInfo.m_uploadPic  = data.UPLOAD_PIC -- 上传头像 url
end

function PhpInfo.reset()
    PhpInfo.m_uploadPic = nil
end

function PhpInfo.getUploadPic()
   return PhpInfo.m_uploadPic
end

return PhpInfo
