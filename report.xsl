<?xml version="1.0" encoding="ISO8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"                                                      

	xmlns:netlims="http://www.netlims.com/namespaces/netlims"
	xmlns:met="http://opensearch.org/searchsuggest2"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	exclude-result-prefixes="met">

  <!-- wikipedia api for search by album details -->
  <xsl:param name="baseUrl" select="'https://en.wikipedia.org/w/api.php?action=opensearch&amp;format=xml&amp;search='" />


  <msxsl:script language="javascript" implements-prefix="netlims">

    <![CDATA[

    function inLast2Years(year, month, day) {

      var curr_date = new Date();
      var curr_year = curr_date.getFullYear();
      var curr_month = curr_date.getFullYear();
      var curr_day = curr_date.getFullYear();

      if (curr_year - year > 2 ) 
      {
        return false;
      }

      if (curr_year - year < 2 ) {
        return true;
      }

      if (curr_year - year == 2 ) {

      if (curr_month - month < 0 ) 
        return true;

      else (curr_month - month > 0) 
        return false;

      }

    }

    ]]>         

  </msxsl:script>


  <xsl:key name="albums-by-country" match="Album" use="Country" />
  <xsl:template match="Albums">
    <html>

      <head>
        <style type="text/css">

         h2 {
         text-decoration: underline;
         color:green;
         }

         tr {
         vertical-align:top;
         font-family: Verdana, Helvetica, sans-serif;
         color:#000000;
         background-color: #FFFFFF;
         }

         tr.head {
         background-color: gray;
         color: #000000;
         font-size:1.2em;
         }
         
         tr.bold {
         font-weight: bold;
         }


         td.highlight {
         background-color: yellow
         }

       </style>

     </head>
     <body>




      <xsl:for-each select="Album[count(. | key('albums-by-country', Country)[1]) = 1]">
       <xsl:sort select="Country" /> 
       <h2> <xsl:value-of select="Country" /> </h2> <br />
       
       <table border="1">
        <tr class="head">
          <th >Artist</th>
          <th>Title</th>
          <th >Company</th>
          <th >Link</th>
          <th >Price</th>
        </tr>

        <xsl:for-each select="key('albums-by-country', Country)">

          <xsl:sort select="Date" />
          <xsl:variable name="year" select="substring(Date,1,4)" />
          <xsl:variable name="month" select="substring(Date,5,2)" />
          <xsl:variable name="day" select="substring(Date,7,2)" />
          
          <xsl:variable name="artist" select="Artist" />

          <xsl:variable name="album_name" select="Name" />
          <xsl:variable name="company" select="Company" />

          <xsl:variable name="price" select="Price" />


          <!-- If the album has not been released in the last two years, bold the line  -->
          <tr>
           <xsl:if test="netlims:inLast2Years($year,$month,$day)!= true()">
             <xsl:attribute name="class">bold</xsl:attribute>
           </xsl:if>

           <td style=" color:red" >
            <xsl:value-of select="$artist"/>
          </td>

           <td>
            <xsl:value-of select="$album_name"/>
            <br/>
            (<xsl:value-of select="$year"/>) 
          </td>

          <td>
            <xsl:value-of select="$company"/>
          </td>

          <td>

            <xsl:variable name="uri1" select="concat($baseUrl ,$album_name, '+',$artist , '+' ,'album' )"/>
            <xsl:variable name="uri2" select="concat($baseUrl ,$album_name )"/>
            <xsl:variable name="doc1" select="document($uri1)//met:Url"/>
            <xsl:variable name="doc2" select="document($uri2)//met:Url"/>


            <xsl:choose>
             <xsl:when test="not($doc1)">
              <a href="{$doc2}"><xsl:value-of select="$doc2"/></a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$doc1}"><xsl:value-of select="$doc1"/></a>
            </xsl:otherwise>
          </xsl:choose>
        </td>

        <td>
          <xsl:value-of select="$price"/>
        </td>

      </tr>

    </xsl:for-each>

    <!-- Total rows -->
    <tr>
      <td colspan="4"> Total Price</td>
      <td class="highlight">
       <xsl:value-of select="sum(key('albums-by-country',Country)/Price)"/>
     </td>
   </tr>

   <tr>
    <td colspan="4"> Total Albums</td>
    <td class="highlight">
     <xsl:value-of select="count(key('albums-by-country',Country))"/>
   </td>
 </tr>


</table>
</xsl:for-each>



</body>
</html>
</xsl:template>



</xsl:stylesheet>

