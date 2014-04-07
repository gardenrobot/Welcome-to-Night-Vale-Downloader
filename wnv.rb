require 'date'
require 'net/http'
require 'nokogiri'

# The URL of the RSS feed
$rssUriStr = 'http://feeds.feedburner.com/WelcomeToNightVale?format=xml'

# The directory to download the mp3 files into
$downloadDir = '/mnt/hd2/Shared/Podcasts/Welcome To Night Vale'

# The last time that the rss was checked
$lastDownloaded = Date.now

# The number of seconds between updates
$updateInterval = 60 * 60 * 12

# Returns a list of all MP3 URIs in the current RSS feed
def getRssList()

    # download rss
    rssUri = URI($rssUriStr)
    rssStr = Net::HTTP.get(rssUri)

    # parse xml
    doc = Nokogiri.XML(rssStr)
    doc.xpath('//media:content/@url').collect{|att| att.value}

end

# Returns the filename of the mp3 uri
def uriToFilename(uriStr)
    uriStr.split('/').last
end

# Returns all files that are downloaded
def getLocalFiles(downloadDir)
    # check that this is a Night Vale mp3 file
    mp3Exp = /\d+_\-_[A-Z].+\.mp3/
    Dir.entries(downloadDir).select { |entry| mp3Exp =~ entry}
end

# Returns a list of uris that still need to be downloaded
def getUrisToDownload(downloadDir)
    
    # get all files from rss
    allRssMp3s = getRssList()

    # get all local files
    allLocalMp3s = getLocalFiles(downloadDir)

    # if a file is already downloaded, remove it
    allRssMp3s.reject{|mp3Uri| allLocalMp3s.include?(uriToFilename(mp3Uri))}

end

# Downloads a file over http into a given directory
def download(uriStr, downloadDir)
    filename = uriToFilename(uriStr)
    filePath = File.join(downloadDir, filename)
    puts ('wget -O "'+ filePath + '" "' + uriStr + '" > /dev/null')
end

# Downloads all missing mp3s
def sync(downloadDir)
    urisToDownload = getUrisToDownload(downloadDir)
    urisToDownload.each{|uri| download(uri, downloadDir)}
end

# Returns true if an episode is expected. WNV episodes are expected on
# the 1st and 15th of every month.
def isEpisodeExpected()
    mday = DateTime.now.to_day.mday
    mday == 1 or mday == 15
end

# Main loop. Checks the rss feed every hour if there is an expected episode
def main()
    sync($downloadDir)
    while true
        if isEpisodeExpected
            sync
        end
        sleep(updateInterval)
    end
end
