// Pratyush Kumar (pratyusk)
// Aaron Berro (abberro)

package project2;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.PreparedStatement;

public class MyFakebookOracle extends FakebookOracle {

    static String prefix = "tajik.";

    // You must use the following variable as the JDBC connection
    Connection oracleConnection = null;

    // You must refer to the following variables for the corresponding tables in your database
    String cityTableName = null;
    String userTableName = null;
    String friendsTableName = null;
    String currentCityTableName = null;
    String hometownCityTableName = null;
    String programTableName = null;
    String educationTableName = null;
    String eventTableName = null;
    String participantTableName = null;
    String albumTableName = null;
    String photoTableName = null;
    String coverPhotoTableName = null;
    String tagTableName = null;


    // DO NOT modify this constructor
    public MyFakebookOracle(String dataType, Connection c) {
        super();
        oracleConnection = c;
        // You will use the following tables in your Java code
        cityTableName = prefix + dataType + "_CITIES";
        userTableName = prefix + dataType + "_USERS";
        friendsTableName = prefix + dataType + "_FRIENDS";
        currentCityTableName = prefix + dataType + "_USER_CURRENT_CITY";
        hometownCityTableName = prefix + dataType + "_USER_HOMETOWN_CITY";
        programTableName = prefix + dataType + "_PROGRAMS";
        educationTableName = prefix + dataType + "_EDUCATION";
        eventTableName = prefix + dataType + "_USER_EVENTS";
        albumTableName = prefix + dataType + "_ALBUMS";
        photoTableName = prefix + dataType + "_PHOTOS";
        tagTableName = prefix + dataType + "_TAGS";
    }


    @Override
    // ***** Query 0 *****
    // This query is given to your for free;
    // You can use it as an example to help you write your own code
    //
    public void findMonthOfBirthInfo() {

        // Scrollable result set allows us to read forward (using next())
        // and also backward.
        // This is needed here to support the user of isFirst() and isLast() methods,
        // but in many cases you will not need it.
        // To create a "normal" (unscrollable) statement, you would simply call
        // Statement stmt = oracleConnection.createStatement();
        //
        try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

            // For each month, find the number of users born that month
            // Sort them in descending order of count
            ResultSet rst = stmt.executeQuery("select count(*), month_of_birth from " +
                    userTableName +
                    " where month_of_birth is not null group by month_of_birth order by 1 desc");

            this.monthOfMostUsers = 0;
            this.monthOfLeastUsers = 0;
            this.totalUsersWithMonthOfBirth = 0;

            // Get the month with most users, and the month with least users.
            // (Notice that this only considers months for which the number of users is > 0)
            // Also, count how many total users have listed month of birth (i.e., month_of_birth not null)
            //
            while (rst.next()) {
                int count = rst.getInt(1);
                int month = rst.getInt(2);
                if (rst.isFirst())
                    this.monthOfMostUsers = month;
                if (rst.isLast())
                    this.monthOfLeastUsers = month;
                this.totalUsersWithMonthOfBirth += count;
            }

            // Get the names of users born in the "most" month
            rst = stmt.executeQuery("select user_id, first_name, last_name from " +
                    userTableName + " where month_of_birth=" + this.monthOfMostUsers);
            while (rst.next()) {
                Long uid = rst.getLong(1);
                String firstName = rst.getString(2);
                String lastName = rst.getString(3);
                this.usersInMonthOfMost.add(new UserInfo(uid, firstName, lastName));
            }

            // Get the names of users born in the "least" month
            rst = stmt.executeQuery("select first_name, last_name, user_id from " +
                    userTableName + " where month_of_birth=" + this.monthOfLeastUsers);
            while (rst.next()) {
                String firstName = rst.getString(1);
                String lastName = rst.getString(2);
                Long uid = rst.getLong(3);
                this.usersInMonthOfLeast.add(new UserInfo(uid, firstName, lastName));
            }

            // Close statement and result set
            rst.close();
            stmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }
    }

    @Override
    // ***** Query 1 *****
    // Find information about users' names:
    // (1) The longest first name (if there is a tie, include all in result)
    // (2) The shortest first name (if there is a tie, include all in result)
    // (3) The most common first name, and the number of times it appears (if there
    //      is a tie, include all in result)
    //
    public void findNameInfo() { // Query1
        // Find the following information from your database and store the information as shown


        try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

            // finding longest, shortest and most common first names of users
            ResultSet rst1 = stmt.executeQuery("SELECT DISTINCT U.FIRST_NAME AS LONGEST_FIRST_NAME FROM " +
                    userTableName +
                    " U WHERE LENGTH(U.FIRST_NAME) = (SELECT MAX(LENGTH(U1.FIRST_NAME)) FROM " + userTableName + "  U1) ORDER BY U.FIRST_NAME");

            while (rst1.next()) {
                this.longestFirstNames.add(rst1.getString(1));
            }

            rst1 = stmt.executeQuery("SELECT DISTINCT U.FIRST_NAME AS SHORTEST_FIRST_NAME FROM " +
                    userTableName +
                    " U WHERE LENGTH(U.FIRST_NAME) = (SELECT MIN(LENGTH(U1.FIRST_NAME)) FROM " + userTableName + "  U1) ORDER BY U.FIRST_NAME");
            while (rst1.next()) {
                this.shortestFirstNames.add(rst1.getString(1));
            }

            rst1 = stmt.executeQuery("SELECT COUNT(*), U.FIRST_NAME AS MOST_COMMON_FIRST_NAME FROM " +
                    userTableName +
                    " U GROUP BY U.FIRST_NAME ORDER BY 1 DESC, U.FIRST_NAME");

            while (rst1.next()) {
                int commonCount = rst1.getInt(1);
                String commonName = rst1.getString(2);
                String mostCommonName = "";
                int mostCommonCount = 0;
                if (rst1.isFirst())
                {
                    this.mostCommonFirstNames.add(commonName);
                    mostCommonName = commonName;
                    mostCommonCount = commonCount;
                    this.mostCommonFirstNamesCount = mostCommonCount;
                }
                else
                {
                    if (commonCount == mostCommonCount)
                    {
                        this.mostCommonFirstNames.add(commonName);
                    }
                }
            }

            // Close statement and result set
            rst1.close();
            stmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }
    }

    @Override
    // ***** Query 2 *****
    // Find the user(s) who have no friends in the network
    //
    // Be careful on this query!
    // Remember that if two users are friends, the friends table
    // only contains the pair of user ids once, subject to
    // the constraint that user1_id < user2_id
    //
    public void lonelyUsers() {
        // Find the following information from your database and store the information as shown
  
      try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

            // finding users with no friends
            ResultSet rst2 = stmt.executeQuery("SELECT U1.USER_ID, U1.FIRST_NAME, U1.LAST_NAME FROM "
             + userTableName + " U1 WHERE U1.USER_ID NOT IN ((SELECT U.USER_ID FROM "
             + userTableName + " U JOIN " + friendsTableName + " F ON F.USER1_ID = U.USER_ID) UNION (SELECT U.USER_ID FROM "
             + userTableName + " U JOIN " + friendsTableName + " F ON F.USER2_ID = U.USER_ID)) ORDER BY U1.USER_ID");
            while (rst2.next()) {
                Long uid = rst2.getLong(1);
                String firstName = rst2.getString(2);
                String lastName = rst2.getString(3);
                this.lonelyUsers.add(new UserInfo(uid, firstName, lastName));
            }


            // Close statement and result set
            rst2.close();
            stmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }





        // this.lonelyUsers.add(new UserInfo(10L, "Billy", "SmellsFunny"));
        // this.lonelyUsers.add(new UserInfo(11L, "Jenny", "BadBreath"));
    }

    @Override
    // ***** Query 3 *****
    // Find the users who do not live in their hometowns
    // (I.e., current_city != hometown_city)
    //
    public void liveAwayFromHome() throws SQLException {
        //this.liveAwayFromHome.add(new UserInfo(11L, "Heather", "Movalot"));


    // -- SELECT U.USER_ID, U.FIRST_NAME, U.LAST_NAME, CC.CITY_NAME, HC.CITY_NAME
    // -- FROM USERS U JOIN USER_HOMETOWN_CITY HC ON (HC.USER_ID = U.USERID)
    // -- JOIN USER_CURRENT_CITY CC ON (CC.USERID = U.USERID);

        try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

            // finding users who no longer live in their hometown
            ResultSet rst3 = stmt.executeQuery("SELECT U.USER_ID, U.FIRST_NAME, U.LAST_NAME FROM " +
                    userTableName +
                    " U JOIN " + 
                    hometownCityTableName + 
                    " HC ON (HC.USER_ID = U.USER_ID) JOIN " +
                    currentCityTableName + 
                    " CC ON (CC.USER_ID = U.USER_ID) WHERE CC.CURRENT_CITY_ID <> HC.HOMETOWN_CITY_ID ORDER BY U.USER_ID "
                    );



            while (rst3.next()) {
                Long uid = rst3.getLong(1);
                String firstName = rst3.getString(2);
                String lastName = rst3.getString(3);
                this.liveAwayFromHome.add(new UserInfo(uid, firstName, lastName));
            }

           

            // Close statement and result set
            rst3.close();
            stmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }


    }

    @Override
    // **** Query 4 ****
    // Find the top-n photos based on the number of tagged users
    // If there are ties, choose the photo with the smaller numeric PhotoID first
    //
    public void findPhotosWithMostTags(int n) {

  



  try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

            // finding most tagged photo
            ResultSet rst4 = stmt.executeQuery("SELECT * FROM ( SELECT T.TAG_PHOTO_ID FROM " +
                    tagTableName +
                    " T GROUP BY T.TAG_PHOTO_ID ORDER BY COUNT(*) DESC, T.TAG_PHOTO_ID) where ROWNUM <= " + n);

            ResultSet rst41 = rst4;
            ResultSet rst42 = rst4;
            while (rst4.next()) {      

                String photoID = rst4.getString(1);
                PhotoInfo p;
                // finding details about the most tagged photo
                rst41 = oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY).executeQuery("SELECT A.ALBUM_ID, A.ALBUM_NAME, P.PHOTO_ID, P.PHOTO_CAPTION, P.PHOTO_LINK FROM " +
                    photoTableName +
                    " P, " + albumTableName + " A WHERE P.PHOTO_ID = " + photoID + " AND A.ALBUM_ID = P.ALBUM_ID");

                while (rst41.next()) {
                    String albumId = rst41.getString(1);
                    String albumName = rst41.getString(2);
                    String photoId = rst41.getString(3);
                    String photoCaption = rst41.getString(4);
                    String photoLink = rst41.getString(5);


                    p = new PhotoInfo(photoId, albumId, albumName, photoCaption, photoLink);
                    TaggedPhotoInfo tp = new TaggedPhotoInfo(p);

              rst42 = oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY).executeQuery("SELECT U.USER_ID, U.FIRST_NAME, U.LAST_NAME FROM " + userTableName + " U JOIN " + tagTableName + " T ON U.USER_ID = T.TAG_SUBJECT_ID WHERE T.TAG_PHOTO_ID = " + photoId);

              while (rst42.next()) {
                tp.addTaggedUser(new UserInfo(rst42.getLong(1), rst42.getString(2), rst42.getString(3)));
              }

              this.photosWithMostTags.add(tp);

                }

            }


            // Close statement and result set
            rst42.close();
            rst41.close();
            rst4.close();
            stmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }

      //  String photoId = "1234567";
      //  String albumId = "123456789";
      //  String albumName = "album1";
      //  String photoCaption = "caption1";
      //  String photoLink = "http://google.com";
      //  PhotoInfo p = new PhotoInfo(photoId, albumId, albumName, photoCaption, photoLink);
      //  TaggedPhotoInfo tp = new TaggedPhotoInfo(p);
      //  tp.addTaggedUser(new UserInfo(12345L, "taggedUserFirstName1", "taggedUserLastName1"));
      //  tp.addTaggedUser(new UserInfo(12345L, "taggedUserFirstName2", "taggedUserLastName2"));
      //  this.photosWithMostTags.add(tp);
    }

    @Override
    // **** Query 5 ****
    // Find suggested "match pairs" of users, using the following criteria:
    // (1) One of the users is female, and the other is male
    // (2) Their age difference is within "yearDiff"
    // (3) They are not friends with one another
    // (4) They should be tagged together in at least one photo
    //
    // You should return up to n "match pairs"
    // If there are more than n match pairs, you should break ties as follows:
    // (i) First choose the pairs with the largest number of shared photos
    // (ii) If there are still ties, choose the pair with the smaller user_id for the female
    // (iii) If there are still ties, choose the pair with the smaller user_id for the male
    //
    public void matchMaker(int n, int yearDiff) {

            try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

            // Created views for not friends pairs and mutual friend pairs
            String getViewNotFriends = "CREATE OR REPLACE VIEW NOT_FRIENDS_MF_AGE_DIFF AS " + 
             "SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM "
             + userTableName + " U1, " + userTableName + " U2 WHERE ABS(U1.YEAR_OF_BIRTH - U2.YEAR_OF_BIRTH) <= 2 AND U1.GENDER = 'female' AND U2.GENDER = 'male' AND NOT EXISTS (SELECT F.USER1_ID FROM "
             + friendsTableName + " F WHERE F.USER1_ID = U1.USER_ID AND F.USER2_ID = U2.USER_ID)";
            String getViewPotentialCouples = "CREATE OR REPLACE VIEW POTENTIAL_COUPLE AS SELECT * FROM " + 
            "(SELECT NF.U1_ID AS PC_ID1, U1.FIRST_NAME AS PC_FN1, U1.LAST_NAME AS PC_LN1, U1.YEAR_OF_BIRTH AS PC_YOB1, " + 
            "NF.U2_ID AS PC_ID2, U2.FIRST_NAME AS PC_FN2, U2.LAST_NAME AS PC_LN2, U2.YEAR_OF_BIRTH AS PC_YOB2, " + 
            "COUNT(*) AS TAG_COUNT FROM NOT_FRIENDS_MF_AGE_DIFF NF INNER JOIN "
             + userTableName + " U1 ON (NF.U1_ID = U1.USER_ID) INNER JOIN "
             + userTableName + " U2 ON (NF.U2_ID = U2.USER_ID) INNER JOIN "
             + tagTableName + " T1 ON (T1.TAG_SUBJECT_ID = NF.U1_ID) INNER JOIN "
             + tagTableName + " T2 ON (T2.TAG_SUBJECT_ID = NF.U2_ID) WHERE T1.TAG_PHOTO_ID = T2.TAG_PHOTO_ID " + 
             "GROUP BY NF.U1_ID, NF.U2_ID, U1.FIRST_NAME, U1.LAST_NAME, U1.YEAR_OF_BIRTH, U2.FIRST_NAME, U2.LAST_NAME, " + 
             "U2.YEAR_OF_BIRTH ORDER BY TAG_COUNT, PC_ID1, PC_ID2) " + 
             "WHERE rownum <= " + n;
            String dropViewPotentialCouples = "DROP VIEW POTENTIAL_COUPLE";
            String dropViewNotFriends = "DROP VIEW NOT_FRIENDS_MF_AGE_DIFF";

            // statements for views
            PreparedStatement getViewNotFriendsStmt = oracleConnection.prepareStatement(getViewNotFriends);
            PreparedStatement getViewPotentialCouplesStmt = oracleConnection.prepareStatement(getViewPotentialCouples);

            PreparedStatement dropViewPotentialCouplesStmt = oracleConnection.prepareStatement(dropViewPotentialCouples);
            PreparedStatement dropViewNotFriendsStmt = oracleConnection.prepareStatement(dropViewNotFriends);


            ResultSet rst5 = null;

            rst5 = getViewNotFriendsStmt.executeQuery();
            rst5 = getViewPotentialCouplesStmt.executeQuery();
            rst5 = stmt.executeQuery("SELECT * FROM POTENTIAL_COUPLE"); // to get potential couples
            ResultSet rst51 = rst5; // to get their common tagged photos

            while (rst5.next()) {      
                Long girlUserId = rst5.getLong(1);
                System.out.println(girlUserId);
                String girlFirstName = rst5.getString(2);
                String girlLastName = rst5.getString(3);
                int girlYear = rst5.getInt(4);
                Long boyUserId = rst5.getLong(5);
                System.out.println(girlUserId);
                String boyFirstName = rst5.getString(6);
                String boyLastName = rst5.getString(7);
                int boyYear = rst5.getInt(8);
                MatchPair mp = new MatchPair(girlUserId, girlFirstName, girlLastName, girlYear,
                                             boyUserId, boyFirstName, boyLastName, boyYear);
                // getting the photos the potential couple is tagged in
                rst51 = oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY).executeQuery("SELECT P.PHOTO_ID AS P_ID, P.ALBUM_ID AS A_ID, A.ALBUM_NAME AS A_NAME, P.PHOTO_CAPTION AS P_CAP, P.PHOTO_LINK AS P_LINK FROM " 
                              + photoTableName + " P INNER JOIN " 
                              + albumTableName + " A ON (P.ALBUM_ID = A.ALBUM_ID), NOT_FRIENDS_MF_AGE_DIFF NF INNER JOIN " 
                              + tagTableName + " T1 ON (T1.TAG_SUBJECT_ID = NF.U1_ID) INNER JOIN " 
                              + tagTableName + " T2 ON (T2.TAG_SUBJECT_ID = NF.U2_ID) " + 
                              "WHERE T1.TAG_PHOTO_ID = T2.TAG_PHOTO_ID AND P.PHOTO_ID = T1.TAG_PHOTO_ID AND " + 
                              "NF.U1_ID = " + girlUserId + " AND NF.U2_ID = " + boyUserId);
                while (rst51.next()) {
                    String sharedPhotoId = rst51.getString(1);
                    String sharedPhotoAlbumId =  rst51.getString(2);
                    String sharedPhotoAlbumName =  rst51.getString(3);
                    String sharedPhotoCaption =  rst51.getString(4);
                    String sharedPhotoLink =  rst51.getString(5);
                    mp.addSharedPhoto(new PhotoInfo(sharedPhotoId, sharedPhotoAlbumId,
                            sharedPhotoAlbumName, sharedPhotoCaption, sharedPhotoLink));
                }

            this.bestMatches.add(mp);

            }

            rst5 = dropViewPotentialCouplesStmt.executeQuery();
            rst5 = dropViewNotFriendsStmt.executeQuery();

            // Close statement and result set
            rst51.close();
            rst5.close();
            stmt.close();
            getViewNotFriendsStmt.close();
            getViewPotentialCouplesStmt.close();
            dropViewPotentialCouplesStmt.close();
            dropViewNotFriendsStmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }

        // Long girlUserId = 123L;
        // String girlFirstName = "girlFirstName";
        // String girlLastName = "girlLastName";
        // int girlYear = 1988;
        // Long boyUserId = 456L;
        // String boyFirstName = "boyFirstName";
        // String boyLastName = "boyLastName";
        // int boyYear = 1986;
        // MatchPair mp = new MatchPair(girlUserId, girlFirstName, girlLastName,
        //         girlYear, boyUserId, boyFirstName, boyLastName, boyYear);
        // String sharedPhotoId = "12345678";
        // String sharedPhotoAlbumId = "123456789";
        // String sharedPhotoAlbumName = "albumName";
        // String sharedPhotoCaption = "caption";
        // String sharedPhotoLink = "link";
        // mp.addSharedPhoto(new PhotoInfo(sharedPhotoId, sharedPhotoAlbumId,
        //         sharedPhotoAlbumName, sharedPhotoCaption, sharedPhotoLink));
        // this.bestMatches.add(mp);
    }

    // **** Query 6 ****
    // Suggest users based on mutual friends
    //
    // Find the top n pairs of users in the database who have the most
    // common friends, but are not friends themselves.
    //
    // Your output will consist of a set of pairs (user1_id, user2_id)
    // No pair should appear in the result twice; you should always order the pairs so that
    // user1_id < user2_id
    //
    // If there are ties, you should give priority to the pair with the smaller user1_id.
    // If there are still ties, give priority to the pair with the smaller user2_id.
    //
    @Override
    public void suggestFriendsByMutualFriends(int n) {

            try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {


            // Created views for not friends pairs and mutual friend pairs
            String getViewNotFriends = "CREATE OR REPLACE VIEW NOT_FRIENDS AS SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM "
             + userTableName + " U1, " + userTableName + 
             " U2 WHERE U1.USER_ID < U2.USER_ID AND U2.USER_ID NOT IN ((SELECT F.USER2_ID FROM "
              + friendsTableName + 
              " F WHERE F.USER1_ID = U1.USER_ID) UNION (SELECT F.USER1_ID FROM " + friendsTableName + 
              " F WHERE F.USER2_ID = U1.USER_ID)) AND U1.USER_ID NOT IN ((SELECT F.USER2_ID FROM " + friendsTableName + 
              " F WHERE F.USER1_ID = U2.USER_ID) UNION (SELECT F.USER1_ID FROM " + friendsTableName + " F WHERE F.USER2_ID = U2.USER_ID))";
            // String getViewNotFriends = "CREATE OR REPLACE VIEW NOT_FRIENDS AS SELECT U1.USER_ID AS U1_ID, U2.USER_ID AS U2_ID FROM "
            //  + userTableName + " U1, " + userTableName + 
            //  " U2 WHERE U1.USER_ID < U2.USER_ID AND NOT EXISTS (SELECT F.USER1_ID FROM "
            //  + friendsTableName + " F WHERE F.USER1_ID = U1.USER_ID AND F.USER2_ID = U2.USER_ID)";
            String getViewU1_MF = "CREATE OR REPLACE VIEW U1_MF AS SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM " + friendsTableName + 
            " F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER1_ID = NF.U1_ID)) FULL OUTER JOIN " + userTableName + 
            " U3 ON ((U3.USER_ID = F.USER2_ID)) UNION ALL SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM "
             + friendsTableName + " F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER2_ID = NF.U1_ID)) FULL OUTER JOIN " 
             + userTableName + " U3 ON ((U3.USER_ID = F.USER1_ID))";
            String getViewU2_MF = "CREATE OR REPLACE VIEW U2_MF AS SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM " + friendsTableName + 
            " F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER1_ID = NF.U2_ID)) FULL OUTER JOIN " + userTableName + 
            " U3 ON ((U3.USER_ID = F.USER2_ID)) UNION ALL SELECT U3.USER_ID AS MF_ID, NF.U1_ID AS NFU1_ID, NF.U2_ID AS NFU2_ID FROM "
             + friendsTableName + " F FULL OUTER JOIN NOT_FRIENDS NF ON ((F.USER2_ID = NF.U2_ID)) FULL OUTER JOIN " 
             + userTableName + " U3 ON ((U3.USER_ID = F.USER1_ID))";
            String getViewMF_Pairs = "CREATE OR REPLACE VIEW MF_PAIRS AS SELECT * FROM " + 
            "(SELECT U1_MF.NFU1_ID AS MF1_ID, U1.FIRST_NAME AS MF1_FN, U1.LAST_NAME AS MF1_LN, " + 
            "U1_MF.NFU2_ID AS MF2_ID, U2.FIRST_NAME AS MF2_FN, U2.LAST_NAME AS MF2_LN, COUNT(*) AS MUTUAL_COUNT FROM " + 
            "U1_MF INNER JOIN U2_MF ON (U1_MF.MF_ID = U2_MF.MF_ID) AND " + 
            "(U1_MF.NFU1_ID = U2_MF.NFU1_ID AND U1_MF.NFU2_ID = U2_MF.NFU2_ID) INNER JOIN " + userTableName + 
            " U1 ON (U1_MF.NFU1_ID = U1.USER_ID) INNER JOIN " + userTableName + 
            " U2 ON (U1_MF.NFU2_ID = U2.USER_ID) " + 
            "GROUP BY U1_MF.NFU1_ID, U1.FIRST_NAME, U1.LAST_NAME, U1_MF.NFU2_ID, U2.FIRST_NAME, U2.LAST_NAME " + 
            "ORDER BY MUTUAL_COUNT DESC, MF1_ID, MF2_ID) WHERE ROWNUM <= " + n;
            String dropViewMF_Pairs = "DROP VIEW MF_PAIRS";
            String dropViewU2_MF = "DROP VIEW U2_MF";
            String dropViewU1_MF = "DROP VIEW U1_MF";
            String dropViewNotFriends = "DROP VIEW NOT_FRIENDS";

            // statements for views
            PreparedStatement getViewNotFriendsStmt = oracleConnection.prepareStatement(getViewNotFriends);
            PreparedStatement getViewU1_MFStmt = oracleConnection.prepareStatement(getViewU1_MF);
            PreparedStatement getViewU2_MFStmt = oracleConnection.prepareStatement(getViewU2_MF);
            PreparedStatement getViewMF_PairsStmt = oracleConnection.prepareStatement(getViewMF_Pairs);

            PreparedStatement dropViewMF_PairsStmt = oracleConnection.prepareStatement(dropViewMF_Pairs);
            PreparedStatement dropViewU2_MFStmt = oracleConnection.prepareStatement(dropViewU2_MF);
            PreparedStatement dropViewU1_MFStmt = oracleConnection.prepareStatement(dropViewU1_MF);
            PreparedStatement dropViewNotFriendsStmt = oracleConnection.prepareStatement(dropViewNotFriends);

            ResultSet rst6 = null;

            rst6 = getViewNotFriendsStmt.executeQuery();
            rst6 = getViewU1_MFStmt.executeQuery();
            rst6 = getViewU2_MFStmt.executeQuery();
            rst6 = getViewMF_PairsStmt.executeQuery();
            rst6 = stmt.executeQuery("SELECT * FROM MF_PAIRS"); // to get potential friends pair
            ResultSet rst61 = rst6; // to get their mutual friends

            while (rst6.next()) {      
                Long user1_id = rst6.getLong(1);
                String user1FirstName = rst6.getString(2);
                String user1LastName = rst6.getString(3);
                Long user2_id = rst6.getLong(4);
                String user2FirstName = rst6.getString(5);
                String user2LastName = rst6.getString(6);
                UsersPair p = new UsersPair(user1_id, user1FirstName, user1LastName, user2_id, user2FirstName, user2LastName);
                rst61 = oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY).executeQuery("SELECT U1_MF.MF_ID AS MF_ID, U.FIRST_NAME AS MF_FN, U.LAST_NAME AS MF_LN FROM U1_MF INNER JOIN U2_MF ON (U1_MF.MF_ID = U2_MF.MF_ID) AND (U1_MF.NFU1_ID = U2_MF.NFU1_ID AND U1_MF.NFU2_ID = U2_MF.NFU2_ID) INNER JOIN " + userTableName + " U ON (U1_MF.MF_ID = U.USER_ID) WHERE U1_MF.NFU1_ID = " + user1_id + " AND U1_MF.NFU2_ID = " + user2_id);
                while (rst61.next()) {
                    p.addSharedFriend(rst61.getLong(1), rst61.getString(2), rst61.getString(3));
                }

            this.suggestedUsersPairs.add(p);

            }
            rst6 = dropViewMF_PairsStmt.executeQuery();
            rst6 = dropViewU2_MFStmt.executeQuery();
            rst6 = dropViewU1_MFStmt.executeQuery();
            rst6 = dropViewNotFriendsStmt.executeQuery();

            // Close statement and result set
            rst61.close();
            rst6.close();
            stmt.close();
            getViewNotFriendsStmt.close();
            getViewU1_MFStmt.close();
            getViewU2_MFStmt.close();
            getViewMF_PairsStmt.close();
            dropViewMF_PairsStmt.close();
            dropViewU2_MFStmt.close();
            dropViewU1_MFStmt.close();
            dropViewNotFriendsStmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }

        // Long user1_id = 123L;
        // String user1FirstName = "User1FirstName";
        // String user1LastName = "User1LastName";
        // Long user2_id = 456L;
        // String user2FirstName = "User2FirstName";
        // String user2LastName = "User2LastName";
        // UsersPair p = new UsersPair(user1_id, user1FirstName, user1LastName, user2_id, user2FirstName, user2LastName);

        // p.addSharedFriend(567L, "sharedFriend1FirstName", "sharedFriend1LastName");
        // p.addSharedFriend(678L, "sharedFriend2FirstName", "sharedFriend2LastName");
        // p.addSharedFriend(789L, "sharedFriend3FirstName", "sharedFriend3LastName");
        // this.suggestedUsersPairs.add(p);
    }

    @Override
    // ***** Query 7 *****
    //
    // Find the name of the state with the most events, as well as the number of
    // events in that state.  If there is a tie, return the names of all of the (tied) states.
    //
    public void findEventStates() {

  try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

            // finding most popular events
            ResultSet rst7 = stmt.executeQuery("SELECT COUNT(*), C.STATE_NAME FROM "
             + eventTableName + " E JOIN " 
             + cityTableName + " C ON (E.EVENT_CITY_ID = C.CITY_ID) GROUP BY C.STATE_NAME ORDER BY COUNT(*) DESC");


            while (rst7.next()) {
                int count = rst7.getInt(1);
                String state = rst7.getString(2);
                int mostPopularCount = 0;
                if (rst7.isFirst())
                {
                                this.popularStateNames.add(state);
                    this.eventCount = count;
                    mostPopularCount = count;
                }
                else
                {
                    if (count == mostPopularCount)
                    {
                      this.popularStateNames.add(state);
                    }
                }
            }

  
            // Close statement and result set
            rst7.close();
            stmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }
  //this.eventCount = 12;
        //this.popularStateNames.add("Michigan");
        //this.popularStateNames.add("California");
        //Do a join of events w/ city, then use a query similar to those in Q0
    }

    //@Override
    // ***** Query 8 *****
    // Given the ID of a user, find information about that
    // user's oldest friend and youngest friend
    //
    // If two users have exactly the same age, meaning that they were born
    // on the same day, then assume that the one with the larger user_id is older
    //
    public void findAgeInfo(Long user_id) {
        //easy way: get all friends of the given user
        //then go through and check ages
    try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

      // finding oldest and youngest friends
      ResultSet rst8 = stmt.executeQuery("SELECT U.USER_ID, U.FIRST_NAME, U.LAST_NAME FROM " + userTableName + " U WHERE U.USER_ID IN ((SELECT F.USER2_ID FROM " + friendsTableName + " F WHERE F.USER1_ID = " + user_id + ") UNION (SELECT F.USER1_ID FROM " + friendsTableName + " F WHERE F.USER2_ID = " + user_id + ")) ORDER BY U.YEAR_OF_BIRTH, U.MONTH_OF_BIRTH, U.DAY_OF_BIRTH, U.USER_ID DESC");

            while (rst8.next()) {
                if (rst8.isFirst())
                {
                  this.oldestFriend = new UserInfo(rst8.getLong(1), rst8.getString(2), rst8.getString(3));
                }
                if (rst8.isLast())
                {
                  this.youngestFriend = new UserInfo(rst8.getLong(1), rst8.getString(2), rst8.getString(3));
                }
            }


            // Close statement and result set
            rst8.close();
            stmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }

        //this.oldestFriend = new UserInfo(1L, "Oliver", "Oldham");
        //this.youngestFriend = new UserInfo(25L, "Yolanda", "Young");
    }

    @Override
    //   ***** Query 9 *****
    //
    // Find pairs of potential siblings.
    //
    // A pair of users are potential siblings if they have the same last name and hometown, if they are friends, and
    // if they are less than 10 years apart in age.  Pairs of siblings are returned with the lower user_id user first
    // on the line.  They are ordered based on the first user_id and in the event of a tie, the second user_id.
    //
    //
    public void findPotentialSiblings() {

        //Select 2 users where the join with hometown city is the same, last name is the same, where they are less than 10yrs apart, and they are also friends

      try (Statement stmt =
                     oracleConnection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,
                             ResultSet.CONCUR_READ_ONLY)) {

        // finding potential siblings
        ResultSet rst9 = stmt.executeQuery("SELECT DISTINCT U1.USER_ID, U1.FIRST_NAME, U1.LAST_NAME, U2.USER_ID, U2.FIRST_NAME, U2.LAST_NAME FROM "
         + userTableName + " U1 JOIN " + userTableName + " U2 ON (U1.LAST_NAME = U2.LAST_NAME) JOIN "
         + hometownCityTableName + " HC1 ON (HC1.USER_ID = U1.USER_ID) JOIN "
         + hometownCityTableName + " HC2 ON (HC2.USER_ID = U2.USER_ID) JOIN "
         + friendsTableName + 
         " F ON (F.USER1_ID = U1.USER_ID) WHERE (HC1.HOMETOWN_CITY_ID = HC2.HOMETOWN_CITY_ID) AND (F.USER2_ID = U2.USER_ID) AND (ABS(U1.YEAR_OF_BIRTH - U2.YEAR_OF_BIRTH) < 10) AND (U1.USER_ID < U2.USER_ID) ORDER BY U1.USER_ID, U2.USER_ID");

            while (rst9.next()) {
                Long user1_id = rst9.getLong(1);
                String user1FirstName = rst9.getString(2);
                String user1LastName = rst9.getString(3);
                Long user2_id = rst9.getLong(4);
                String user2FirstName = rst9.getString(5);
                String user2LastName =  rst9.getString(6);
                SiblingInfo s = new SiblingInfo(user1_id, user1FirstName, user1LastName, user2_id, user2FirstName, user2LastName);
                this.siblings.add(s);
            }


            // Close statement and result set
            rst9.close();
            stmt.close();
        } catch (SQLException err) {
            System.err.println(err.getMessage());
        }

        //Long user1_id = 123L;
        //String user1FirstName = "User1FirstName";
        //String user1LastName = "User1LastName";
        //Long user2_id = 456L;
        //String user2FirstName = "User2FirstName";
        //String user2LastName = "User2LastName";
        //SiblingInfo s = new SiblingInfo(user1_id, user1FirstName, user1LastName, user2_id, user2FirstName, user2LastName);
        //this.siblings.add(s);
    }

}